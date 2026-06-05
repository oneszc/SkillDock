import XCTest
@testable import SkillDockCore

final class SkillWorkspaceServiceTests: XCTestCase {
    func testFileTreeListsRelativePathsWithoutWritingFiles() async throws {
        let skillDirectory = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: skillDirectory)
        try Fixtures.write(
            "print('hello')",
            to: skillDirectory.appendingPathComponent("scripts/run.py")
        )
        let before = try Fixtures.snapshot(directory: skillDirectory)

        let paths = try await SkillWorkspaceService().fileTree(for: skillDirectory)

        XCTAssertEqual(paths, ["scripts", "scripts/run.py", "SKILL.md"])
        XCTAssertEqual(try Fixtures.snapshot(directory: skillDirectory), before)
    }

    func testSavingNoteRefreshesRecordWithoutChangingSkillHash() async throws {
        let library = try Fixtures.temporaryDirectory()
        let skillDirectory = library.appendingPathComponent("sample-skill")
        try Fixtures.makeSkill(at: skillDirectory)
        let notesDirectory = try Fixtures.temporaryDirectory()
        let notesStore = NotesStore(directory: notesDirectory)
        let libraryService = SkillLibraryService(notesStore: notesStore)
        let workspace = SkillWorkspaceService(notesStore: notesStore)
        let settings = SkillSettings(
            libraryPath: library,
            codexPath: try Fixtures.temporaryDirectory(),
            claudePath: try Fixtures.temporaryDirectory()
        )
        let original = try await libraryService.refresh(settings: settings).first!
        let note = SkillNote(
            key: SkillNoteKey(
                name: original.skill.name,
                source: original.skill.source,
                contentHash: original.skill.contentHash
            ),
            chineseName: "示例技能",
            chineseDescription: "中文说明",
            tags: ["示例"],
            useCases: [],
            riskLevel: .low,
            riskNote: "",
            usageNote: "",
            updatedAt: Date()
        )

        try await workspace.save(note: note)
        let refreshed = try await libraryService.refresh(settings: settings).first!

        XCTAssertEqual(refreshed.note?.chineseName, "示例技能")
        XCTAssertEqual(refreshed.skill.contentHash, original.skill.contentHash)
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: skillDirectory.appendingPathComponent(".skilldock.json").path
            )
        )
    }

    func testImportAndInstallCopySkillsToConfiguredLocations() async throws {
        let source = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: source)
        let settings = SkillSettings(
            libraryPath: try Fixtures.temporaryDirectory(),
            codexPath: try Fixtures.temporaryDirectory(),
            claudePath: try Fixtures.temporaryDirectory()
        )
        let workspace = SkillWorkspaceService()

        _ = try await workspace.importSkill(
            from: source,
            settings: settings,
            strategy: .skip
        )
        _ = try await workspace.installSkill(
            from: source,
            target: .codex,
            settings: settings,
            strategy: .skip
        )

        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: settings.libraryPath
                    .appendingPathComponent(source.lastPathComponent)
                    .appendingPathComponent("SKILL.md").path
            )
        )
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: settings.codexPath
                    .appendingPathComponent(source.lastPathComponent)
                    .appendingPathComponent("SKILL.md").path
            )
        )
    }
}
