import Foundation
import XCTest
@testable import SkillDockCore

final class RemoteUpdateServiceTests: XCTestCase {
    func testCheckReturnsUpToDateWhenHashesMatch() async throws {
        let fixture = try await makeUpdateFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }

        let update = try await fixture.service.check(fixture.source)

        XCTAssertEqual(update.status, .upToDate)
        XCTAssertEqual(update.currentContentHash, fixture.installedHash)
        XCTAssertEqual(update.remoteContentHash, fixture.installedHash)
        XCTAssertEqual(update.currentCommit, "abc123")
        XCTAssertEqual(update.remoteCommit, "abc123")
    }

    func testCheckReturnsUpdateAvailableWhenRemoteHashDiffersAndLocalIsUnmodified() async throws {
        let fixture = try await makeUpdateFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        try Fixtures.write(
            "Remote change",
            to: fixture.remoteSkill.appendingPathComponent("CHANGELOG.md")
        )

        let update = try await fixture.service.check(fixture.source)

        XCTAssertEqual(update.status, .updateAvailable)
        XCTAssertEqual(update.currentContentHash, fixture.installedHash)
        XCTAssertNotEqual(update.remoteContentHash, fixture.installedHash)
    }

    func testCheckReturnsLocalModifiedWhenLocalHashDiffersFromInstalledHash() async throws {
        let fixture = try await makeUpdateFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        try Fixtures.write(
            "Local change",
            to: fixture.localSkill.appendingPathComponent("LOCAL.md")
        )

        let update = try await fixture.service.check(fixture.source)

        XCTAssertEqual(update.status, .localModified)
        XCTAssertNotEqual(update.currentContentHash, fixture.installedHash)
    }

    func testCheckBuildsFileChangePreview() async throws {
        let fixture = try await makeUpdateFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        try Fixtures.write(
            "Local only",
            to: fixture.localSkill.appendingPathComponent("LOCAL.md")
        )
        try Fixtures.write(
            "Remote only",
            to: fixture.remoteSkill.appendingPathComponent("REMOTE.md")
        )
        try Fixtures.write(
            "# Remote version",
            to: fixture.remoteSkill.appendingPathComponent("SKILL.md")
        )

        let update = try await fixture.service.check(fixture.source)

        XCTAssertEqual(update.addedFiles, ["REMOTE.md"])
        XCTAssertEqual(update.modifiedFiles, ["SKILL.md"])
        XCTAssertEqual(update.removedFiles, ["LOCAL.md"])
    }

    func testConfirmedReplacementUpdatesLibraryAndSourceRecord() async throws {
        let fixture = try await makeUpdateFixture(remoteCommit: "def456")
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        try Fixtures.write(
            "# Remote version",
            to: fixture.remoteSkill.appendingPathComponent("SKILL.md")
        )
        let update = try await fixture.service.check(fixture.source)
        XCTAssertEqual(update.status, .updateAvailable)

        let replacement = try await fixture.service.replaceWithRemote(
            update,
            libraryPath: fixture.localSkill.deletingLastPathComponent()
        )

        let skillMarkdown = try String(
            contentsOf: fixture.localSkill.appendingPathComponent("SKILL.md"),
            encoding: .utf8
        )
        XCTAssertEqual(skillMarkdown, "# Remote version")
        XCTAssertEqual(replacement.destination, fixture.localSkill)
        XCTAssertEqual(replacement.source.commit, "def456")
        XCTAssertEqual(replacement.source.installedContentHash, update.remoteContentHash)
        let storedSource = try await fixture.sourceStore.source(for: fixture.localSkill)
        XCTAssertEqual(storedSource?.commit, "def456")
        XCTAssertEqual(storedSource?.installedContentHash, update.remoteContentHash)
    }

    func testReplacementRejectsLocalModifiedSkill() async throws {
        let fixture = try await makeUpdateFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        try Fixtures.write(
            "Local change",
            to: fixture.localSkill.appendingPathComponent("LOCAL.md")
        )
        let update = try await fixture.service.check(fixture.source)
        XCTAssertEqual(update.status, .localModified)

        do {
            _ = try await fixture.service.replaceWithRemote(
                update,
                libraryPath: fixture.localSkill.deletingLastPathComponent()
            )
            XCTFail("Expected local modified replacement to fail.")
        } catch let error as RemoteUpdateError {
            XCTAssertEqual(error, .localModifiedSkill)
        }
    }

    private func makeUpdateFixture(remoteCommit: String = "abc123") async throws -> UpdateFixture {
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(".build/test-tmp/\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let localSkill = root.appendingPathComponent("example", isDirectory: true)
        try Fixtures.makeSkill(at: localSkill, name: "example")
        let remoteRoot = root.appendingPathComponent("remote", isDirectory: true)
        let remoteSkill = remoteRoot.appendingPathComponent("skills/example")
        try FileManager.default.createDirectory(
            at: remoteSkill.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try FileManager.default.copyItem(at: localSkill, to: remoteSkill)
        let hash = try SkillHasher().hash(directory: localSkill)
        let source = RemoteSkillSource(
            destination: localSkill,
            skillName: "example",
            repositoryURL: URL(string: "https://github.com/owner/repository")!,
            owner: "owner",
            repository: "repository",
            branch: "main",
            repositoryRelativePath: "skills/example",
            requestedMethod: .automatic,
            actualMethod: .gitClone,
            commit: "abc123",
            installedContentHash: hash
        )
        let sourceStore = RemoteSourceStore(directory: root.appendingPathComponent("app-support"))
        try await sourceStore.save([source])
        let repository = RemoteRepository(
            reference: GitHubRepositoryReference(
                owner: "owner",
                repository: "repository",
                branch: "main"
            ),
            localRoot: remoteRoot,
            method: .gitClone,
            commit: remoteCommit,
            requiresCleanup: false
        )
        let service = RemoteUpdateService(
            repositoryService: RemoteRepositoryService(
                cloneProvider: StubRepositoryProvider(repository: repository),
                zipProvider: StubRepositoryProvider(repository: repository)
            ),
            sourceStore: sourceStore
        )
        return UpdateFixture(
            root: root,
            localSkill: localSkill,
            remoteSkill: remoteSkill,
            installedHash: hash,
            source: source,
            sourceStore: sourceStore,
            service: service
        )
    }
}

private struct UpdateFixture {
    let root: URL
    let localSkill: URL
    let remoteSkill: URL
    let installedHash: String
    let source: RemoteSkillSource
    let sourceStore: RemoteSourceStore
    let service: RemoteUpdateService

    init(
        root: URL,
        localSkill: URL,
        remoteSkill: URL,
        installedHash: String,
        source: RemoteSkillSource,
        sourceStore: RemoteSourceStore,
        service: RemoteUpdateService
    ) {
        self.root = root
        self.localSkill = localSkill
        self.remoteSkill = remoteSkill
        self.installedHash = installedHash
        self.source = source
        self.sourceStore = sourceStore
        self.service = service
    }
}

private actor StubRepositoryProvider: RemoteRepositoryProviding {
    let repository: RemoteRepository

    init(repository: RemoteRepository) {
        self.repository = repository
    }

    func acquire(_ reference: GitHubRepositoryReference) async throws -> RemoteRepository {
        repository
    }
}
