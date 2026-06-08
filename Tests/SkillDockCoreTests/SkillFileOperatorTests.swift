import XCTest
@testable import SkillDockCore

final class SkillFileOperatorTests: XCTestCase {
    func testRejectsImportWithoutSkillMarkdown() async throws {
        let source = try Fixtures.temporaryDirectory()
        let destination = try Fixtures.temporaryDirectory()

        do {
            _ = try await SkillFileOperator().copySkill(
                from: source,
                to: destination,
                strategy: .skip
            )
            XCTFail("Expected invalid skill error")
        } catch {
            XCTAssertEqual(error as? SkillFileOperationError, .missingSkillMarkdown)
        }
    }

    func testSkipConflictLeavesDestinationUnchanged() async throws {
        let source = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: source, description: "new")
        let destinationRoot = try Fixtures.temporaryDirectory()
        let existing = destinationRoot.appendingPathComponent(source.lastPathComponent)
        try Fixtures.makeSkill(at: existing, description: "existing")
        let before = try Fixtures.snapshot(directory: existing)

        let result = try await SkillFileOperator().copySkill(
            from: source,
            to: destinationRoot,
            strategy: .skip
        )

        guard case let .skipped(skippedURL) = result else {
            return XCTFail("Expected skipped result")
        }
        XCTAssertEqual(skippedURL.standardizedFileURL.path, existing.standardizedFileURL.path)
        XCTAssertEqual(try Fixtures.snapshot(directory: existing), before)
    }

    func testOverwriteOnlyHappensWithExplicitOverwriteStrategy() async throws {
        let source = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: source, description: "new")
        let destinationRoot = try Fixtures.temporaryDirectory()
        let existing = destinationRoot.appendingPathComponent(source.lastPathComponent)
        try Fixtures.makeSkill(at: existing, description: "existing")

        _ = try await SkillFileOperator().copySkill(
            from: source,
            to: destinationRoot,
            strategy: .overwrite
        )

        XCTAssertEqual(
            try String(contentsOf: existing.appendingPathComponent("SKILL.md"), encoding: .utf8),
            try String(contentsOf: source.appendingPathComponent("SKILL.md"), encoding: .utf8)
        )
    }

    func testRenameCreatesUniqueDestination() async throws {
        let source = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: source)
        let destinationRoot = try Fixtures.temporaryDirectory()
        try FileManager.default.createDirectory(
            at: destinationRoot.appendingPathComponent(source.lastPathComponent),
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: destinationRoot.appendingPathComponent("\(source.lastPathComponent)-copy"),
            withIntermediateDirectories: true
        )

        let result = try await SkillFileOperator().copySkill(
            from: source,
            to: destinationRoot,
            strategy: .rename
        )

        XCTAssertEqual(
            result,
            .copied(destinationRoot.appendingPathComponent("\(source.lastPathComponent)-copy-2"))
        )
    }

    func testCopyDoesNotIncludeExternalSkillDockNotes() async throws {
        let source = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: source)
        let appSupport = try Fixtures.temporaryDirectory()
        try Fixtures.write("notes", to: appSupport.appendingPathComponent("notes.json"))
        let destinationRoot = try Fixtures.temporaryDirectory()

        let result = try await SkillFileOperator().copySkill(
            from: source,
            to: destinationRoot,
            strategy: .skip
        )

        guard case let .copied(destination) = result else {
            return XCTFail("Expected copied result")
        }
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: destination.appendingPathComponent("notes.json").path)
        )
    }

    func testRejectsChangesToSystemSkill() async throws {
        let source = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: source)

        do {
            _ = try await SkillFileOperator().copySkill(
                from: source,
                to: try Fixtures.temporaryDirectory(),
                strategy: .skip,
                isSystemSkill: true
            )
            XCTFail("Expected system skill rejection")
        } catch {
            XCTAssertEqual(error as? SkillFileOperationError, .systemSkillIsReadOnly)
        }
    }

    func testRemoveSkillDeletesOnlyChildInsideExpectedRoot() async throws {
        let targetRoot = try Fixtures.temporaryDirectory()
        let target = targetRoot.appendingPathComponent("sample-skill")
        let sibling = targetRoot.appendingPathComponent("other-skill")
        try Fixtures.makeSkill(at: target)
        try Fixtures.makeSkill(at: sibling)

        try await SkillFileOperator().removeSkill(
            named: "sample-skill",
            from: targetRoot,
            isSystemSkill: false
        )

        XCTAssertFalse(FileManager.default.fileExists(atPath: target.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: sibling.path))
    }

    func testRemoveSkillRejectsSystemSkill() async throws {
        let targetRoot = try Fixtures.temporaryDirectory()
        let target = targetRoot.appendingPathComponent("sample-skill")
        try Fixtures.makeSkill(at: target)

        do {
            try await SkillFileOperator().removeSkill(
                named: "sample-skill",
                from: targetRoot,
                isSystemSkill: true
            )
            XCTFail("Expected system skill rejection")
        } catch {
            XCTAssertEqual(error as? SkillFileOperationError, .systemSkillIsReadOnly)
        }

        XCTAssertTrue(FileManager.default.fileExists(atPath: target.path))
    }

    func testRemoveSkillRejectsDestinationOutsideExpectedRoot() async throws {
        let parent = try Fixtures.temporaryDirectory()
        let targetRoot = parent.appendingPathComponent("installed")
        let outside = parent.appendingPathComponent("outside-skill")
        try FileManager.default.createDirectory(at: targetRoot, withIntermediateDirectories: true)
        try Fixtures.makeSkill(at: outside)

        do {
            try await SkillFileOperator().removeSkill(
                named: "../outside-skill",
                from: targetRoot
            )
            XCTFail("Expected destination outside root rejection")
        } catch {
            XCTAssertEqual(error as? SkillFileOperationError, .destinationOutsideRoot)
        }

        XCTAssertTrue(FileManager.default.fileExists(atPath: outside.path))
    }

    func testRemoveSkillRejectsSymbolicLinkOutsideExpectedRoot() async throws {
        let parent = try Fixtures.temporaryDirectory()
        let targetRoot = parent.appendingPathComponent("installed")
        let outside = parent.appendingPathComponent("outside-skill")
        let symbolicLink = targetRoot.appendingPathComponent("linked-skill")
        try FileManager.default.createDirectory(at: targetRoot, withIntermediateDirectories: true)
        try Fixtures.makeSkill(at: outside)
        try FileManager.default.createSymbolicLink(at: symbolicLink, withDestinationURL: outside)

        do {
            try await SkillFileOperator().removeSkill(
                named: "linked-skill",
                from: targetRoot
            )
            XCTFail("Expected destination outside root rejection")
        } catch {
            XCTAssertEqual(error as? SkillFileOperationError, .destinationOutsideRoot)
        }

        XCTAssertTrue(FileManager.default.fileExists(atPath: symbolicLink.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: outside.path))
    }

    func testRemoveSkillRejectsRegularFile() async throws {
        let targetRoot = try Fixtures.temporaryDirectory()
        let target = targetRoot.appendingPathComponent("sample-skill")
        try Fixtures.write("not a skill", to: target)

        do {
            try await SkillFileOperator().removeSkill(
                named: "sample-skill",
                from: targetRoot
            )
            XCTFail("Expected invalid skill rejection")
        } catch {
            XCTAssertEqual(error as? SkillFileOperationError, .missingSkillMarkdown)
        }

        XCTAssertTrue(FileManager.default.fileExists(atPath: target.path))
    }

    func testRemoveSkillRejectsDirectoryWithoutSkillMarkdown() async throws {
        let targetRoot = try Fixtures.temporaryDirectory()
        let target = targetRoot.appendingPathComponent("sample-skill")
        try FileManager.default.createDirectory(at: target, withIntermediateDirectories: true)

        do {
            try await SkillFileOperator().removeSkill(
                named: "sample-skill",
                from: targetRoot
            )
            XCTFail("Expected invalid skill rejection")
        } catch {
            XCTAssertEqual(error as? SkillFileOperationError, .missingSkillMarkdown)
        }

        XCTAssertTrue(FileManager.default.fileExists(atPath: target.path))
    }

    func testRemoveSkillRejectsDanglingSymbolicLink() async throws {
        let targetRoot = try Fixtures.temporaryDirectory()
        let symbolicLink = targetRoot.appendingPathComponent("sample-skill")
        let missingTarget = targetRoot.appendingPathComponent("missing-target")
        try FileManager.default.createSymbolicLink(
            at: symbolicLink,
            withDestinationURL: missingTarget
        )

        do {
            try await SkillFileOperator().removeSkill(
                named: "sample-skill",
                from: targetRoot
            )
            XCTFail("Expected invalid skill rejection")
        } catch {
            XCTAssertEqual(error as? SkillFileOperationError, .missingSkillMarkdown)
        }

        XCTAssertNoThrow(try FileManager.default.destinationOfSymbolicLink(atPath: symbolicLink.path))
    }

    func testRemoveSkillDoesNothingWhenDestinationIsMissing() async throws {
        let targetRoot = try Fixtures.temporaryDirectory()

        try await SkillFileOperator().removeSkill(
            named: "missing-skill",
            from: targetRoot
        )

        XCTAssertTrue(FileManager.default.fileExists(atPath: targetRoot.path))
    }
}
