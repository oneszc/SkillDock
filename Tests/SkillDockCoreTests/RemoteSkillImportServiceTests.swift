import Foundation
import XCTest
@testable import SkillDockCore

final class RemoteSkillImportServiceTests: XCTestCase {
    func testImportsOnlySelectedCandidatesAndSavesCopiedSources() async throws {
        let root = try Fixtures.temporaryDirectory()
        let first = root.appendingPathComponent("skills/first", isDirectory: true)
        let second = root.appendingPathComponent("skills/second", isDirectory: true)
        try Fixtures.makeSkill(at: first, name: "first")
        try Fixtures.makeSkill(at: second, name: "second")
        let library = try Fixtures.temporaryDirectory()
        let sourceStore = RemoteSourceStore(directory: try Fixtures.temporaryDirectory())
        let service = RemoteSkillImportService(sourceStore: sourceStore)

        let result = await service.importSelected(
            candidates: [
                candidate(at: first, relativePath: "skills/first", selected: true),
                candidate(at: second, relativePath: "skills/second", selected: false)
            ],
            repository: repository(root: root),
            requestedMethod: .automatic,
            libraryPath: library
        )

        XCTAssertEqual(result.copied.count, 1)
        XCTAssertEqual(result.skipped.count, 0)
        XCTAssertEqual(result.failures.count, 0)
        XCTAssertTrue(FileManager.default.fileExists(atPath: library.appendingPathComponent("first").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: library.appendingPathComponent("second").path))
        let sources = try await sourceStore.load()
        XCTAssertEqual(sources.count, 1)
        XCTAssertEqual(sources.first?.repositoryRelativePath, "skills/first")
        XCTAssertEqual(sources.first?.destination.lastPathComponent, "first")
    }

    func testUsesPerCandidateConflictStrategyAndReportsFailures() async throws {
        let root = try Fixtures.temporaryDirectory()
        let overwrite = root.appendingPathComponent("skills/overwrite", isDirectory: true)
        let skip = root.appendingPathComponent("skills/skip", isDirectory: true)
        let missing = root.appendingPathComponent("skills/missing", isDirectory: true)
        try Fixtures.makeSkill(at: overwrite, name: "overwrite", description: "remote")
        try Fixtures.makeSkill(at: skip, name: "skip", description: "remote")
        let library = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: library.appendingPathComponent("overwrite"), description: "local")
        try Fixtures.makeSkill(at: library.appendingPathComponent("skip"), description: "local")
        let service = RemoteSkillImportService(
            sourceStore: RemoteSourceStore(directory: try Fixtures.temporaryDirectory())
        )

        let result = await service.importSelected(
            candidates: [
                candidate(
                    at: overwrite,
                    relativePath: "skills/overwrite",
                    selected: true,
                    strategy: .overwrite
                ),
                candidate(at: skip, relativePath: "skills/skip", selected: true, strategy: .skip),
                candidate(at: missing, relativePath: "skills/missing", selected: true)
            ],
            repository: repository(root: root),
            requestedMethod: .gitClone,
            libraryPath: library
        )

        XCTAssertEqual(result.copied.count, 1)
        XCTAssertEqual(result.skipped.count, 1)
        XCTAssertEqual(result.failures.count, 1)
        XCTAssertEqual(
            try String(
                contentsOf: library.appendingPathComponent("overwrite/SKILL.md"),
                encoding: .utf8
            ),
            try String(contentsOf: overwrite.appendingPathComponent("SKILL.md"), encoding: .utf8)
        )
    }

    private func candidate(
        at source: URL,
        relativePath: String,
        selected: Bool,
        strategy: ConflictStrategy = .skip
    ) -> RemoteSkillCandidate {
        RemoteSkillCandidate(
            sourceURL: source,
            repositoryRelativePath: relativePath,
            name: source.lastPathComponent,
            description: nil,
            contentHash: "hash-\(source.lastPathComponent)",
            relativePaths: ["SKILL.md"],
            fileCount: 1,
            hasScripts: false,
            hasConflict: false,
            isSelected: selected,
            strategy: strategy
        )
    }

    private func repository(root: URL) -> RemoteRepository {
        RemoteRepository(
            reference: GitHubRepositoryReference(
                owner: "owner",
                repository: "repository",
                branch: "main"
            ),
            localRoot: root,
            method: .gitClone,
            commit: "abc123",
            requiresCleanup: false
        )
    }
}
