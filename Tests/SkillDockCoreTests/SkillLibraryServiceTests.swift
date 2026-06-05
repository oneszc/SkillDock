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
}
