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
}
