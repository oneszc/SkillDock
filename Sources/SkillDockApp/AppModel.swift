import Foundation
import Observation
import AppKit
import SkillDockCore

@MainActor
@Observable
final class AppModel {
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

    private let settingsStore: SettingsStore
    private let libraryService: SkillLibraryService
    private let workspaceService: SkillWorkspaceService
    private let importPreviewService: ImportPreviewService
    private let search = SkillSearch()

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

    func saveNote(
        chineseName: String,
        chineseDescription: String,
        tags: String,
        usageNote: String,
        riskLevel: RiskLevel,
        riskNote: String
    ) async {
        guard let record = selectedRecord else { return }
        let note = SkillNote(
            key: SkillNoteKey(
                name: record.skill.name,
                source: record.skill.source,
                contentHash: record.skill.contentHash
            ),
            chineseName: chineseName,
            chineseDescription: chineseDescription,
            tags: tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            useCases: record.note?.useCases ?? [],
            riskLevel: riskLevel,
            riskNote: riskNote,
            usageNote: usageNote,
            updatedAt: Date()
        )
        do {
            try await workspaceService.save(note: note)
            await refresh()
            operationMessage = "Chinese notes saved outside the original Skill."
        } catch {
            errorMessage = error.localizedDescription
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
