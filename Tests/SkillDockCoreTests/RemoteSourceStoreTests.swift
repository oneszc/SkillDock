import Foundation
import XCTest
@testable import SkillDockCore

final class RemoteSourceStoreTests: XCTestCase {
    func testRoundTripsRemoteSources() async throws {
        let store = RemoteSourceStore(directory: try Fixtures.temporaryDirectory())
        let source = makeSource(destination: URL(fileURLWithPath: "/library/example"))

        try await store.save([source])

        let loaded = try await store.load()
        XCTAssertEqual(loaded, [source])
    }

    func testUpsertReplacesRecordForSameDestination() async throws {
        let store = RemoteSourceStore(directory: try Fixtures.temporaryDirectory())
        let destination = URL(fileURLWithPath: "/library/example")
        try await store.upsert(makeSource(destination: destination, commit: "old"))

        try await store.upsert(makeSource(destination: destination, commit: "new"))

        let sources = try await store.load()
        XCTAssertEqual(sources.count, 1)
        XCTAssertEqual(sources.first?.commit, "new")
    }

    func testRemovesRecordForDestination() async throws {
        let store = RemoteSourceStore(directory: try Fixtures.temporaryDirectory())
        let destination = URL(fileURLWithPath: "/library/example")
        try await store.upsert(makeSource(destination: destination))

        try await store.remove(destination: destination)

        let sources = try await store.load()
        XCTAssertTrue(sources.isEmpty)
    }

    func testStoresRecordsOutsideSkillFolder() async throws {
        let skill = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: skill)
        let appSupport = try Fixtures.temporaryDirectory()
        let store = RemoteSourceStore(directory: appSupport)

        try await store.upsert(makeSource(destination: skill))

        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: appSupport.appendingPathComponent("remote-sources.json").path
            )
        )
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: skill.appendingPathComponent(".skilldock-source.json").path
            )
        )
    }

    private func makeSource(
        destination: URL,
        commit: String = "abc123"
    ) -> RemoteSkillSource {
        RemoteSkillSource(
            destination: destination,
            skillName: "example",
            repositoryURL: URL(string: "https://github.com/owner/repository")!,
            owner: "owner",
            repository: "repository",
            branch: "main",
            repositoryRelativePath: "skills/example",
            requestedMethod: .automatic,
            actualMethod: .gitClone,
            commit: commit,
            installedContentHash: "hash",
            lastCheckedAt: Date(timeIntervalSince1970: 10)
        )
    }
}
