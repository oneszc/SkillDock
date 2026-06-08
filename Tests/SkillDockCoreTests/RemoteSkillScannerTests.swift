import XCTest
@testable import SkillDockCore

final class RemoteSkillScannerTests: XCTestCase {
    func testScansMultipleSkillsAndPreselectsFolderLink() async throws {
        let repositoryRoot = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(
            at: repositoryRoot.appendingPathComponent("skills/writer"),
            name: "writer",
            description: "Write content"
        )
        try Fixtures.makeSkillWithFiles(
            at: repositoryRoot.appendingPathComponent("tools/reviewer"),
            name: "reviewer"
        )
        let library = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: library.appendingPathComponent("reviewer"))
        let reference = GitHubRepositoryReference(
            owner: "owner",
            repository: "repository",
            branch: "main",
            folderPath: "skills/writer"
        )
        let repository = RemoteRepository(
            reference: reference,
            localRoot: repositoryRoot,
            method: .gitClone,
            commit: "abc123",
            requiresCleanup: false
        )

        let candidates = try await RemoteSkillScanner().scan(
            repository: repository,
            libraryPath: library
        )

        XCTAssertEqual(candidates.map(\.name), ["reviewer", "writer"])
        let writer = try XCTUnwrap(candidates.first { $0.name == "writer" })
        XCTAssertEqual(writer.repositoryRelativePath, "skills/writer")
        XCTAssertTrue(writer.isSelected)
        XCTAssertFalse(writer.hasScripts)
        XCTAssertFalse(writer.hasConflict)
        let reviewer = try XCTUnwrap(candidates.first { $0.name == "reviewer" })
        XCTAssertFalse(reviewer.isSelected)
        XCTAssertTrue(reviewer.hasScripts)
        XCTAssertTrue(reviewer.hasConflict)
        XCTAssertEqual(reviewer.strategy, .skip)
        XCTAssertEqual(reviewer.fileCount, 3)
    }
}
