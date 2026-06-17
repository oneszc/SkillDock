import Foundation
import SkillDockCore
import XCTest
@testable import SkillDockApp

@MainActor
final class AppModelConfirmationTests: XCTestCase {
    func testConfirmedUninstallUsesCapturedRequestAfterDialogStateClears() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let library = root.appendingPathComponent("library", isDirectory: true)
        let codex = root.appendingPathComponent("codex", isDirectory: true)
        let claude = root.appendingPathComponent("claude", isDirectory: true)
        let notes = root.appendingPathComponent("notes", isDirectory: true)
        let skill = codex.appendingPathComponent("sample-skill", isDirectory: true)
        try FileManager.default.createDirectory(at: skill, withIntermediateDirectories: true)
        try Data("---\nname: sample-skill\n---\n".utf8)
            .write(to: skill.appendingPathComponent("SKILL.md"))
        defer { try? FileManager.default.removeItem(at: root) }

        let scanned = await SkillScanner().scan([ScanLocation(root: codex, source: .codex)])
        let settings = SkillSettings(libraryPath: library, codexPath: codex, claudePath: claude)
        let model = AppModel(
            settingsStore: SettingsStore(directory: notes, defaultSettings: settings),
            libraryService: SkillLibraryService(notesStore: NotesStore(directory: notes)),
            workspaceService: SkillWorkspaceService(notesStore: NotesStore(directory: notes))
        )
        model.settings = settings
        let request = AppModel.PendingUninstall(
            agentID: AgentTargetID.codex,
            skillName: "sample-skill",
            contentHash: try XCTUnwrap(scanned.first?.contentHash),
            isSystemSkill: false
        )

        model.pendingUninstall = nil
        await model.confirmUninstall(request)

        XCTAssertFalse(FileManager.default.fileExists(atPath: skill.path))
        XCTAssertEqual(model.operationMessage, "Removed from Codex.")
    }
}
