import Foundation
import XCTest
@testable import SkillDockCore

final class GitHubZipRepositoryProviderTests: XCTestCase {
    func testDownloadsAndExtractsRepositoryArchive() async throws {
        let temporaryRoot = try Fixtures.temporaryDirectory()
        let archiveData = try await makeArchiveData(in: temporaryRoot)
        let extractionRoot = temporaryRoot.appendingPathComponent("extraction", isDirectory: true)
        let reference = GitHubRepositoryReference(owner: "owner", repository: "repository")
        let metadata = GitHubRepositoryMetadata(
            branch: "main",
            commit: "abc123",
            archiveURL: URL(string: "https://example.com/repository.zip")!
        )
        let provider = GitHubZipRepositoryProvider(
            temporaryDirectory: extractionRoot,
            metadataResolver: { _ in metadata },
            archiveDownloader: { _ in archiveData }
        )

        let repository = try await provider.acquire(reference)

        XCTAssertEqual(repository.method, .zip)
        XCTAssertEqual(repository.commit, "abc123")
        XCTAssertTrue(repository.requiresCleanup)
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repository.localRoot.appendingPathComponent("skills/example/SKILL.md").path
            )
        )
        XCTAssertEqual(repository.reference.branch, "main")
    }

    private func makeArchiveData(in temporaryRoot: URL) async throws -> Data {
        let wrapper = temporaryRoot.appendingPathComponent("repository-main", isDirectory: true)
        let skill = wrapper.appendingPathComponent("skills/example", isDirectory: true)
        try FileManager.default.createDirectory(at: skill, withIntermediateDirectories: true)
        try "---\nname: example\n---\n".write(
            to: skill.appendingPathComponent("SKILL.md"),
            atomically: true,
            encoding: .utf8
        )
        let archive = temporaryRoot.appendingPathComponent("repository.zip")
        _ = try await CommandRunner().run(
            executable: URL(fileURLWithPath: "/usr/bin/zip"),
            arguments: ["-q", "-r", archive.path, wrapper.lastPathComponent],
            currentDirectory: temporaryRoot
        )
        return try Data(contentsOf: archive)
    }
}
