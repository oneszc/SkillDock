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
