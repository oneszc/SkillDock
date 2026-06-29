import XCTest
@testable import SkillDockCore

final class RemoteRepositoryPluginDetectorTests: XCTestCase {
    func testDetectsCodexPluginManifest() throws {
        let root = try Fixtures.temporaryDirectory()
        try makeManifest(at: root.appendingPathComponent(".codex-plugin/plugin.json"))

        let kinds = RemoteRepositoryPluginDetector().detect(in: root)

        XCTAssertEqual(kinds, [.codex])
    }

    func testDetectsClaudePluginManifest() throws {
        let root = try Fixtures.temporaryDirectory()
        try makeManifest(at: root.appendingPathComponent(".claude-plugin/plugin.json"))

        let kinds = RemoteRepositoryPluginDetector().detect(in: root)

        XCTAssertEqual(kinds, [.claude])
    }

    func testDetectsBothPluginManifests() throws {
        let root = try Fixtures.temporaryDirectory()
        try makeManifest(at: root.appendingPathComponent(".codex-plugin/plugin.json"))
        try makeManifest(at: root.appendingPathComponent(".claude-plugin/plugin.json"))

        let kinds = RemoteRepositoryPluginDetector().detect(in: root)

        XCTAssertEqual(kinds, [.codex, .claude])
    }

    private func makeManifest(at url: URL) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try Data("{}".utf8).write(to: url)
    }
}
