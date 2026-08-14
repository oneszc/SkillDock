import XCTest
@testable import SkillDockCore

final class CodexPluginSkillSourceResolverTests: XCTestCase {
    func testResolverReturnsSkillsDirectoryDeclaredByPluginManifest() throws {
        let home = try Fixtures.temporaryDirectory()
        let version = home.appendingPathComponent(".codex/plugins/cache/openai-curated-remote/superpowers/6.2.0")
        let plugin = version.appendingPathComponent(".codex-plugin")
        let skills = version.appendingPathComponent("skills")
        try FileManager.default.createDirectory(at: plugin, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: skills, withIntermediateDirectories: true)
        try Data(#"{"name":"superpowers","version":"6.2.0","skills":"./skills/"}"#.utf8)
            .write(to: plugin.appendingPathComponent("plugin.json"))

        let result = CodexPluginSkillSourceResolver().resolve(homeDirectory: home)

        XCTAssertEqual(result.locations.map(\.root), [skills.standardizedFileURL])
        XCTAssertEqual(result.locations.map(\.source), [.available(.plugin)])
        XCTAssertTrue(result.issues.isEmpty)
    }

    func testResolverSkipsPluginWithoutSkillsPath() throws {
        let home = try Fixtures.temporaryDirectory()
        let plugin = home.appendingPathComponent(".codex/plugins/cache/openai-bundled/visualize/1.0.20/.codex-plugin")
        try FileManager.default.createDirectory(at: plugin, withIntermediateDirectories: true)
        try Data(#"{"name":"visualize","version":"1.0.20"}"#.utf8)
            .write(to: plugin.appendingPathComponent("plugin.json"))

        let result = CodexPluginSkillSourceResolver().resolve(homeDirectory: home)

        XCTAssertTrue(result.locations.isEmpty)
        XCTAssertTrue(result.issues.isEmpty)
    }

    func testResolverSkipsAmbiguousMultipleVersionsAndReportsIssue() throws {
        let home = try Fixtures.temporaryDirectory()
        try makePluginManifest(home: home, provider: "openai-curated-remote", plugin: "superpowers", version: "6.1.0")
        try makePluginManifest(home: home, provider: "openai-curated-remote", plugin: "superpowers", version: "6.2.0")

        let result = CodexPluginSkillSourceResolver().resolve(homeDirectory: home)

        XCTAssertTrue(result.locations.isEmpty)
        XCTAssertEqual(result.issues.count, 1)
        XCTAssertTrue(result.issues[0].message.contains("Multiple plugin versions"))
    }

    func testResolverSkipsInvalidManifestAndReportsIssue() throws {
        let home = try Fixtures.temporaryDirectory()
        let plugin = home.appendingPathComponent(".codex/plugins/cache/openai-curated-remote/broken/1.0.0/.codex-plugin")
        try FileManager.default.createDirectory(at: plugin, withIntermediateDirectories: true)
        try Data("{".utf8).write(to: plugin.appendingPathComponent("plugin.json"))

        let result = CodexPluginSkillSourceResolver().resolve(homeDirectory: home)

        XCTAssertTrue(result.locations.isEmpty)
        XCTAssertEqual(result.issues.count, 1)
        XCTAssertTrue(result.issues[0].message.contains("Could not read Plugin manifest"))
    }

    func testResolverSkipsSkillsPathOutsideVersionRootWithMatchingPrefix() throws {
        let home = try Fixtures.temporaryDirectory()
        let versionRoot = home.appendingPathComponent(".codex/plugins/cache/openai-curated-remote/example/1.0.0")
        let pluginDirectory = versionRoot.appendingPathComponent(".codex-plugin")
        let rogueSkills = versionRoot
            .deletingLastPathComponent()
            .appendingPathComponent("1.0.0-rogue/skills")
        try FileManager.default.createDirectory(at: pluginDirectory, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: rogueSkills, withIntermediateDirectories: true)
        try Data(#"{"name":"example","version":"1.0.0","skills":"../1.0.0-rogue/skills"}"#.utf8)
            .write(to: pluginDirectory.appendingPathComponent("plugin.json"))

        let result = CodexPluginSkillSourceResolver().resolve(homeDirectory: home)

        XCTAssertTrue(result.locations.isEmpty)
        XCTAssertTrue(result.issues.isEmpty)
    }

    func testResolverSkipsSkillsPathSymlinkedOutsideVersionRoot() throws {
        let home = try Fixtures.temporaryDirectory()
        let versionRoot = home.appendingPathComponent(".codex/plugins/cache/openai-curated-remote/example/1.0.0")
        let pluginDirectory = versionRoot.appendingPathComponent(".codex-plugin")
        let skillsLink = versionRoot.appendingPathComponent("skills-link")
        let externalSkills = home.appendingPathComponent("external-skills")
        try FileManager.default.createDirectory(at: pluginDirectory, withIntermediateDirectories: true)
        try Fixtures.makeSkill(at: externalSkills.appendingPathComponent("outside-skill"))
        try FileManager.default.createSymbolicLink(
            atPath: skillsLink.path,
            withDestinationPath: externalSkills.path
        )
        try Data(#"{"name":"example","version":"1.0.0","skills":"./skills-link/"}"#.utf8)
            .write(to: pluginDirectory.appendingPathComponent("plugin.json"))

        let result = CodexPluginSkillSourceResolver().resolve(homeDirectory: home)

        XCTAssertTrue(result.locations.isEmpty)
        XCTAssertFalse(result.locations.contains { $0.root == externalSkills })
        XCTAssertTrue(result.issues.isEmpty)
    }

    func testResolverDoesNotFindUndeclaredSkillMarkdownElsewhereInCache() throws {
        let home = try Fixtures.temporaryDirectory()
        let rogue = home.appendingPathComponent(".codex/plugins/cache/openai-curated-remote/rogue/1.0.0/random-skill")
        try FileManager.default.createDirectory(at: rogue, withIntermediateDirectories: true)
        try Data("# Rogue".utf8).write(to: rogue.appendingPathComponent("SKILL.md"))

        let result = CodexPluginSkillSourceResolver().resolve(homeDirectory: home)

        XCTAssertTrue(result.locations.isEmpty)
        XCTAssertTrue(result.issues.isEmpty)
    }

    private func makePluginManifest(
        home: URL,
        provider: String,
        plugin: String,
        version: String
    ) throws {
        let versionRoot = home.appendingPathComponent(".codex/plugins/cache/\(provider)/\(plugin)/\(version)")
        let pluginDirectory = versionRoot.appendingPathComponent(".codex-plugin")
        try FileManager.default.createDirectory(at: pluginDirectory, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: versionRoot.appendingPathComponent("skills"), withIntermediateDirectories: true)
        try Data(#"{"name":"\#(plugin)","version":"\#(version)","skills":"./skills/"}"#.utf8)
            .write(to: pluginDirectory.appendingPathComponent("plugin.json"))
    }
}
