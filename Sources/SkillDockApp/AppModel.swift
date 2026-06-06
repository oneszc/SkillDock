import Foundation
import Observation
import AppKit
import SkillDockCore

@MainActor
@Observable
final class AppModel {
    enum NoteSaveState: Equatable {
        case idle
        case pending
        case saving
        case saved
        case failed(String)
    }

    enum PendingOverwrite {
        case install(InstallTarget)
    }

    var records: [SkillRecord] = []
    var selectionID: SkillRecord.ID?
    var navigationSection: NavigationSection = .library
    var searchQuery = ""
    var settings: SkillSettings = .defaults()
    var isRefreshing = false
    var errorMessage: String?
    var markdown = ""
    var filePaths: [String] = []
    var operationMessage: String?
    var pendingOverwrite: PendingOverwrite?
    var importPreview: ImportPreview?
    var importErrorMessage: String?
    var noteDraft = NoteDraft(note: nil)
    var noteSuggestions = NoteSuggestions(tags: [], useCases: [])
    var noteSaveState: NoteSaveState = .idle

    private let settingsStore: SettingsStore
    private let libraryService: SkillLibraryService
    private let workspaceService: SkillWorkspaceService
    private let importPreviewService: ImportPreviewService
    private let search = SkillSearch()
    private var noteSaveTask: Task<Void, Never>?
    private var noteDraftSkill: Skill?

    init(
        settingsStore: SettingsStore = .init(),
        libraryService: SkillLibraryService = .init(),
        workspaceService: SkillWorkspaceService = .init(),
        importPreviewService: ImportPreviewService = .init()
    ) {
        self.settingsStore = settingsStore
        self.libraryService = libraryService
        self.workspaceService = workspaceService
        self.importPreviewService = importPreviewService
    }

    var filteredRecords: [SkillRecord] {
        let sectionRecords = records.filter { record in
            switch navigationSection {
            case .library:
                record.skill.source == .library
            case .installed:
                record.skill.installation.codex || record.skill.installation.claude
            case .system:
                record.skill.isSystem
            case .settings:
                false
            }
        }
        return search.filter(sectionRecords, query: searchQuery)
    }

    var selectedRecord: SkillRecord? {
        records.first { $0.id == selectionID }
    }

    func start() async {
        do {
            settings = try await settingsStore.load()
            applyAppearance(settings.appearanceMode)
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            records = try await libraryService.refresh(settings: settings)
            preserveOrSelectFirstRecord()
            await loadSelectedDetail()
            await loadNoteDraft()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadSelectedDetail() async {
        guard let record = selectedRecord else {
            markdown = ""
            filePaths = []
            return
        }
        do {
            markdown = try await workspaceService.markdown(for: record.skill.path)
            filePaths = try await workspaceService.fileTree(for: record.skill.path)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadNoteDraft() async {
        noteSaveTask?.cancel()
        noteDraft = NoteDraft(note: selectedRecord?.note)
        noteDraftSkill = selectedRecord?.skill
        noteSaveState = .idle
        do {
            noteSuggestions = try await workspaceService.noteSuggestions()
        } catch {
            noteSuggestions = NoteSuggestions(tags: [], useCases: [])
        }
    }

    func updateNoteDraft(_ draft: NoteDraft) {
        noteDraft = draft
        noteSaveState = .pending
        noteSaveTask?.cancel()
        noteSaveTask = Task {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            await saveCurrentNoteDraft()
        }
    }

    func flushPendingNoteSave() async {
        guard noteSaveState == .pending else { return }
        noteSaveTask?.cancel()
        await saveCurrentNoteDraft()
    }

    func saveCurrentNoteDraft() async {
        guard let skill = noteDraftSkill else { return }
        noteSaveState = .saving
        do {
            try await workspaceService.save(draft: noteDraft, for: skill)
            noteSuggestions = try await workspaceService.noteSuggestions()
            noteSaveState = .saved
        } catch {
            noteSaveState = .failed("Chinese notes could not be saved.")
        }
    }

    func requestInstall(to target: InstallTarget) async {
        guard settings.defaultConflictStrategy == .overwrite else {
            await installSelected(to: target, strategy: settings.defaultConflictStrategy)
            return
        }
        pendingOverwrite = .install(target)
    }

    func installSelected(to target: InstallTarget, strategy: ConflictStrategy) async {
        guard let record = selectedRecord else { return }
        do {
            let result = try await workspaceService.installSkill(
                from: record.skill.path,
                target: target,
                settings: settings,
                strategy: strategy,
                isSystemSkill: record.skill.isSystem
            )
            operationMessage = result.message
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func requestImport() async {
        let panel = NSOpenPanel()
        panel.title = "Choose a Skill folder"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let source = panel.url else { return }
        await prepareImport(urls: [source])
    }

    func prepareImport(urls: [URL]) async {
        do {
            importPreview = try await importPreviewService.preview(
                urls: urls,
                libraryPath: settings.libraryPath
            )
            importErrorMessage = nil
        } catch ImportPreviewError.requiresSingleFolder {
            importErrorMessage = "Choose one Skill folder."
        } catch ImportPreviewError.missingSkillMarkdown {
            importErrorMessage = "This folder is not a valid Skill. SKILL.md was not found."
        } catch {
            importErrorMessage = "SkillDock could not inspect this folder."
        }
    }

    func confirmImport() async {
        guard let preview = importPreview else { return }
        do {
            let result = try await workspaceService.importSkill(
                preview: preview,
                settings: settings
            )
            importPreview = nil
            operationMessage = result.message
            await refresh()
            if case .copied(let destination) = result {
                selectionID = records.first {
                    $0.skill.path.standardizedFileURL == destination.standardizedFileURL
                }?.id
            }
        } catch {
            importErrorMessage = "Import failed. The existing Skill was not modified."
        }
    }

    func updateImportStrategy(_ strategy: ConflictStrategy) {
        importPreview?.strategy = strategy
    }

    func confirmOverwrite() async {
        guard case .install(let target) = pendingOverwrite else { return }
        pendingOverwrite = nil
        await installSelected(to: target, strategy: .overwrite)
    }

    func saveSettings() async {
        do {
            try await settingsStore.save(settings)
            operationMessage = "Settings saved."
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectAppearanceMode(_ mode: AppearanceMode) async {
        applyAppearance(mode)
        settings.appearanceMode = mode
        do {
            var persistedSettings = try await settingsStore.load()
            persistedSettings.appearanceMode = mode
            try await settingsStore.save(persistedSettings)
        } catch {
            errorMessage = "Appearance could not be saved."
        }
    }

    private func applyAppearance(_ mode: AppearanceMode) {
        NSApp.appearance = switch mode {
        case .system: nil
        case .light: NSAppearance(named: .aqua)
        case .dark: NSAppearance(named: .darkAqua)
        }
    }

    func revealSelectedInFinder() {
        guard let record = selectedRecord else { return }
        NSWorkspace.shared.activateFileViewerSelecting([record.skill.path])
    }

    func copySelectedPath() {
        guard let record = selectedRecord else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(record.skill.path.path, forType: .string)
        operationMessage = "Path copied."
    }

    private func preserveOrSelectFirstRecord() {
        guard records.contains(where: { $0.id == selectionID }) else {
            selectionID = filteredRecords.first?.id
            return
        }
    }
}

private extension SkillFileOperationResult {
    var message: String {
        switch self {
        case .copied(let destination):
            "Copied to \(destination.path)."
        case .skipped(let destination):
            "Skipped because \(destination.path) already exists."
        }
    }
}
