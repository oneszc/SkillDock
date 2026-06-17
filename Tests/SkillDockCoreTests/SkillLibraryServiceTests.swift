import XCTest
@testable import SkillDockCore

final class SkillLibraryServiceTests: XCTestCase {
    func testRefreshScansConfiguredLocationsAndBuildsRecords() async throws {
        let home = try Fixtures.temporaryDirectory()
        let settings = SkillSettings.defaults(homeDirectory: home)
        try Fixtures.makeSkill(
            at: settings.libraryPath.appendingPathComponent("library-skill"),
            name: "library-skill"
        )
        try Fixtures.makeSkill(
            at: settings.codexPath.appendingPathComponent("codex-skill"),
            name: "codex-skill"
        )
        let notesStore = NotesStore(directory: try Fixtures.temporaryDirectory())
        let service = SkillLibraryService(notesStore: notesStore)

        let records = try await service.refresh(settings: settings)

        XCTAssertEqual(records.map(\.skill.name), ["codex-skill", "library-skill"])
    }

    func testRefreshScansEnabledDynamicAgentTargets() async throws {
        let home = try Fixtures.temporaryDirectory()
        let libraryPath = home.appendingPathComponent("AI-Skills", isDirectory: true)
        let codexPath = home.appendingPathComponent(".codex/skills", isDirectory: true)
        let claudePath = home.appendingPathComponent(".claude/skills", isDirectory: true)
        let geminiPath = home.appendingPathComponent(".gemini/skills", isDirectory: true)
        var settings = SkillSettings(
            libraryPath: libraryPath,
            codexPath: codexPath,
            claudePath: claudePath,
            agentTargets: [
                AgentTarget(
                    id: AgentTargetID.codex,
                    displayName: "Codex",
                    path: codexPath,
                    isEnabled: false,
                    logoAssetName: "codex"
                ),
                AgentTarget(
                    id: AgentTargetID.gemini,
                    displayName: "Gemini",
                    path: geminiPath,
                    isEnabled: true
                )
            ]
        )
        settings.showSystemSkills = true
        try Fixtures.makeSkill(
            at: codexPath.appendingPathComponent("codex-skill"),
            name: "codex-skill"
        )
        try Fixtures.makeSkill(
            at: geminiPath.appendingPathComponent("gemini-skill"),
            name: "gemini-skill"
        )
        let service = SkillLibraryService(
            notesStore: NotesStore(directory: try Fixtures.temporaryDirectory())
        )

        let records = try await service.refresh(settings: settings)

        XCTAssertEqual(records.map(\.skill.name), ["gemini-skill"])
        XCTAssertEqual(records.first?.skill.source, .agent(AgentTargetID.gemini))
        XCTAssertEqual(records.first?.skill.installation.agentIDs, [AgentTargetID.gemini])
    }

    func testRefreshHidesSystemSkillsWhenSettingIsDisabled() async throws {
        let home = try Fixtures.temporaryDirectory()
        var settings = SkillSettings.defaults(homeDirectory: home)
        settings.showSystemSkills = false
        try Fixtures.makeSkill(
            at: settings.codexPath.appendingPathComponent(".system/system-skill"),
            name: "system-skill"
        )
        let service = SkillLibraryService(
            notesStore: NotesStore(directory: try Fixtures.temporaryDirectory())
        )

        let records = try await service.refresh(settings: settings)

        XCTAssertTrue(records.isEmpty)
    }

    func testRefreshAttachesRemoteSourceToLibrarySkill() async throws {
        let home = try Fixtures.temporaryDirectory()
        let appSupport = try Fixtures.temporaryDirectory()
        let settings = SkillSettings.defaults(homeDirectory: home)
        let skillDirectory = settings.libraryPath.appendingPathComponent("remote-skill")
        try Fixtures.makeSkill(at: skillDirectory, name: "remote-skill")
        let sourceStore = RemoteSourceStore(directory: appSupport)
        let source = RemoteSkillSource(
            destination: skillDirectory,
            skillName: "remote-skill",
            repositoryURL: URL(string: "https://github.com/owner/repository")!,
            owner: "owner",
            repository: "repository",
            branch: "main",
            repositoryRelativePath: "skills/remote-skill",
            requestedMethod: .automatic,
            actualMethod: .gitClone,
            commit: "abc123",
            installedContentHash: "hash"
        )
        try await sourceStore.upsert(source)
        let service = SkillLibraryService(
            notesStore: NotesStore(directory: appSupport),
            remoteSourceStore: sourceStore
        )

        let records = try await service.refresh(settings: settings)

        XCTAssertEqual(records.first?.skill.name, "remote-skill")
        XCTAssertEqual(records.first?.remoteSource, source)
    }
}
