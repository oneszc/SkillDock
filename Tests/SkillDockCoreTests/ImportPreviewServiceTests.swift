import XCTest
@testable import SkillDockCore

final class ImportPreviewServiceTests: XCTestCase {
    func testBuildsReadOnlyPreviewForValidSkill() async throws {
        let source = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkillWithFiles(at: source, name: "writer")
        let library = try Fixtures.temporaryDirectory()
        let before = try Fixtures.snapshot(directory: source)

        let preview = try await ImportPreviewService().preview(
            urls: [source],
            libraryPath: library
        )

        XCTAssertEqual(preview.name, "writer")
        XCTAssertEqual(preview.sourceURL, source)
        XCTAssertEqual(preview.fileCount, 3)
        XCTAssertEqual(
            preview.relativePaths,
            ["references", "references/guide.md", "scripts", "scripts/run.py", "SKILL.md"]
        )
        XCTAssertTrue(preview.hasScripts)
        XCTAssertFalse(preview.hasConflict)
        XCTAssertEqual(preview.strategy, .skip)
        XCTAssertEqual(try Fixtures.snapshot(directory: source), before)
        XCTAssertTrue(
            (try FileManager.default.contentsOfDirectory(atPath: library.path)).isEmpty
        )
    }

    func testRejectsAnythingExceptOneValidSkillFolder() async throws {
        let invalidFolder = try Fixtures.temporaryDirectory()
        let file = invalidFolder.appendingPathComponent("note.txt")
        try Fixtures.write("text", to: file)
        let service = ImportPreviewService()

        await XCTAssertThrowsErrorAsync {
            _ = try await service.preview(urls: [], libraryPath: invalidFolder)
        } verify: {
            XCTAssertEqual($0 as? ImportPreviewError, .requiresSingleFolder)
        }
        await XCTAssertThrowsErrorAsync {
            _ = try await service.preview(
                urls: [invalidFolder, invalidFolder],
                libraryPath: invalidFolder
            )
        } verify: {
            XCTAssertEqual($0 as? ImportPreviewError, .requiresSingleFolder)
        }
        await XCTAssertThrowsErrorAsync {
            _ = try await service.preview(urls: [file], libraryPath: invalidFolder)
        } verify: {
            XCTAssertEqual($0 as? ImportPreviewError, .requiresSingleFolder)
        }
        await XCTAssertThrowsErrorAsync {
            _ = try await service.preview(urls: [invalidFolder], libraryPath: invalidFolder)
        } verify: {
            XCTAssertEqual($0 as? ImportPreviewError, .missingSkillMarkdown)
        }
    }

    func testPreviewMarksExistingLibraryConflict() async throws {
        let source = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: source)
        let library = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: library.appendingPathComponent(source.lastPathComponent))

        let preview = try await ImportPreviewService().preview(
            urls: [source],
            libraryPath: library
        )

        XCTAssertTrue(preview.hasConflict)
        XCTAssertEqual(preview.strategy, .skip)
    }
}

private func XCTAssertThrowsErrorAsync<T>(
    _ expression: @escaping () async throws -> T,
    verify: (Error) -> Void,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Expected expression to throw", file: file, line: line)
    } catch {
        verify(error)
    }
}
