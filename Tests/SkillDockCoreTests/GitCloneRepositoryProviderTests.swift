import XCTest
@testable import SkillDockCore

final class GitCloneRepositoryProviderTests: XCTestCase {
    func testClonesIntoManagedRepositoryAndReturnsCommit() async throws {
        let fixture = try Fixtures.makeGitRemoteWithSkill()
        let repositories = try Fixtures.temporaryDirectory()
        let reference = GitHubRepositoryReference(
            owner: "owner",
            repository: "repository",
            branch: "main"
        )
        let provider = GitCloneRepositoryProvider(repositoriesDirectory: repositories)

        let repository = try await provider.acquire(reference, cloneURL: fixture.remote)

        XCTAssertEqual(repository.method, .gitClone)
        XCTAssertEqual(repository.commit, fixture.commit)
        XCTAssertFalse(repository.requiresCleanup)
        XCTAssertEqual(repository.localRoot.deletingLastPathComponent(), repositories)
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repository.localRoot
                    .appendingPathComponent("skills/example/SKILL.md").path
            )
        )
    }

    func testRefreshesExistingManagedRepository() async throws {
        let fixture = try Fixtures.makeGitRemoteWithSkill()
        let repositories = try Fixtures.temporaryDirectory()
        let reference = GitHubRepositoryReference(
            owner: "owner",
            repository: "repository",
            branch: "main"
        )
        let provider = GitCloneRepositoryProvider(repositoriesDirectory: repositories)
        let first = try await provider.acquire(reference, cloneURL: fixture.remote)

        let second = try await provider.acquire(reference, cloneURL: fixture.remote)

        XCTAssertEqual(second.localRoot, first.localRoot)
        XCTAssertEqual(second.commit, first.commit)
    }
}
