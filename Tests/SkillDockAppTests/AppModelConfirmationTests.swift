import Foundation
import XCTest
@testable import SkillDockApp
@testable import SkillDockCore

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

        let scanResult = await SkillScanner().scan([ScanLocation(root: codex, source: .codex)])
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
            contentHash: try XCTUnwrap(scanResult.skills.first?.contentHash),
            isSystemSkill: false
        )

        model.pendingUninstall = nil
        await model.confirmUninstall(request)

        XCTAssertFalse(FileManager.default.fileExists(atPath: skill.path))
        XCTAssertEqual(model.operationMessage, "Removed from Codex.")
    }

    func testRefreshKeepsScanWarningAndClearsItWhenNextScanHasNoIssues() async throws {
        let home = try temporaryDirectory()
        let warningRoot = try temporaryDirectory()
        let cleanRoot = try temporaryDirectory()
        var settings = SkillSettings.defaults(homeDirectory: home)
        settings.libraryPath = warningRoot
        let scanner = scannerReportingWarning(at: warningRoot)
        let model = AppModel(
            settingsStore: SettingsStore(
                directory: try temporaryDirectory(),
                defaultSettings: settings
            ),
            libraryService: SkillLibraryService(
                scanner: scanner,
                notesStore: NotesStore(directory: try temporaryDirectory()),
                homeDirectory: home
            )
        )
        model.settings = settings

        await model.refresh()

        XCTAssertTrue(model.errorMessage?.contains("Scan warning.") == true)

        model.settings.libraryPath = cleanRoot
        await model.refresh()

        XCTAssertNil(model.errorMessage)
    }

    func testRefreshPrefersDetailErrorOverScanWarning() async throws {
        let home = try temporaryDirectory()
        let library = try temporaryDirectory()
        let skill = library.appendingPathComponent("detail-skill")
        let skillFile = skill.appendingPathComponent("SKILL.md")
        try FileManager.default.createDirectory(at: skill, withIntermediateDirectories: true)
        try Data("---\nname: detail-skill\n---\n".utf8).write(to: skillFile)
        var settings = SkillSettings.defaults(homeDirectory: home)
        settings.libraryPath = library
        let scanner = scannerReportingWarning(at: library)
        let model = AppModel(
            settingsStore: SettingsStore(
                directory: try temporaryDirectory(),
                defaultSettings: settings
            ),
            libraryService: SkillLibraryService(
                scanner: scanner,
                notesStore: NotesStore(directory: try temporaryDirectory()),
                homeDirectory: home,
                afterScan: { _ in
                    try FileManager.default.removeItem(at: skillFile)
                }
            )
        )
        model.settings = settings

        await model.refresh()

        XCTAssertNotNil(model.errorMessage)
        XCTAssertNotEqual(model.errorMessage, "Could not completely read Library skills at \(library.path): Scan warning.")
        XCTAssertTrue(model.errorMessage?.contains("SKILL.md") == true)
    }
}

private enum AppModelTestError: LocalizedError {
    case scanWarning

    var errorDescription: String? {
        "Scan warning."
    }
}

private func temporaryDirectory() throws -> URL {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
}

private func scannerReportingWarning(at root: URL) -> SkillScanner {
    SkillScanner(enumeratorProvider: { url, keys, errorHandler in
        if url.standardizedFileURL == root.standardizedFileURL {
            _ = errorHandler?(url, AppModelTestError.scanWarning)
        }
        return FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: keys,
            options: []
        )
    })
}
