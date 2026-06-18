import Foundation
import Observation
import AppKit
import SkillDockCore

@MainActor
@Observable
final class AppModel {
    enum TranslationOperationState: Equatable {
        case idle
        case generating(skillID: String)
        case succeeded(skillID: String)
        case failed(skillID: String, message: String)
    }

    enum TranslationConnectionState: Equatable {
        case idle
        case testing
        case succeeded
        case failed(String)
    }

    enum NoteSaveState: Equatable {
        case idle
        case pending
        case saving
        case saved
        case failed(String)
    }

    enum PendingOverwrite {
        case install(String)
    }

    struct PendingUninstall {
        let agentID: String
        let skillName: String
        let contentHash: String
        let isSystemSkill: Bool
    }

    var records: [SkillRecord] = []
    var selectionID: SkillRecord.ID?
    var navigationSection: NavigationSection = .library
    var agentFilter: AgentFilter = .all
    var searchQuery = ""
    var settings: SkillSettings = .defaults()
    var isRefreshing = false
    var errorMessage: String?
    var markdown = ""
    var filePaths: [String] = []
    var operationMessage: String?
    var pendingOverwrite: PendingOverwrite?
    var pendingUninstall: PendingUninstall?
    var importPreview: ImportPreview?
    var importErrorMessage: String?
    var noteDraft = NoteDraft(note: nil)
    var noteSuggestions = NoteSuggestions(tags: [], useCases: [])
    var noteSaveState: NoteSaveState = .idle
    var isRemoteImportPresented = false
    var remoteImport = RemoteImportModel()
    var remoteUpdate: RemoteSkillUpdate?
    var isRemoteUpdatePreviewPresented = false
    var isCheckingRemoteUpdate = false
    var translationOperationState: TranslationOperationState = .idle
    var translationConnectionState: TranslationConnectionState = .idle
    var translationAPIKey = ""

    private let settingsStore: SettingsStore
    private let libraryService: SkillLibraryService
    private let workspaceService: SkillWorkspaceService
    private let importPreviewService: ImportPreviewService
    private let remoteUpdateService: RemoteUpdateService
    private let translationService: any SkillTranslationServicing
    private let translationCredentialStore: any TranslationCredentialStoring
    private let search = SkillSearch()
    private var noteSaveTask: Task<Void, Never>?
    private var noteDraftSkill: Skill?

    init(
        settingsStore: SettingsStore = .init(),
        libraryService: SkillLibraryService = .init(),
        workspaceService: SkillWorkspaceService = .init(),
        importPreviewService: ImportPreviewService = .init(),
        remoteUpdateService: RemoteUpdateService = .init(
            repositoryService: RemoteRepositoryService(
                cloneProvider: GitCloneRepositoryProvider(),
                zipProvider: GitHubZipRepositoryProvider()
            )
        ),
        translationService: any SkillTranslationServicing = SkillTranslationService(),
        translationCredentialStore: any TranslationCredentialStoring = KeychainTranslationCredentialStore()
    ) {
        self.settingsStore = settingsStore
        self.libraryService = libraryService
        self.workspaceService = workspaceService
        self.importPreviewService = importPreviewService
        self.remoteUpdateService = remoteUpdateService
        self.translationService = translationService
        self.translationCredentialStore = translationCredentialStore
    }

    var filteredRecords: [SkillRecord] {
        let sectionRecords = records.filter { record in
            switch navigationSection {
            case .library:
                record.skill.source == .library
            case .installed:
                !record.skill.installation.agentIDs.isEmpty
            case .system:
                record.skill.isSystem
            }
        }
        let agentFilteredRecords = sectionRecords.filter { record in
            switch (navigationSection, agentFilter) {
            case (.system, _), (_, .all):
                true
            case (_, .agent(let id)):
                isInstalled(record.skill.installation, in: id)
            }
        }
        return search.filter(agentFilteredRecords, query: searchQuery)
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

    func hasTranslationAPIKey() async -> Bool {
        await translationService.hasAPIKey(settings: settings.translation)
    }

    func loadTranslationAPIKey() async {
        do {
            translationAPIKey = try await translationCredentialStore.apiKey(
                providerID: settings.translation.providerID
            ) ?? ""
        } catch {
            translationConnectionState = .failed(error.localizedDescription)
        }
    }

    func saveTranslationAPIKey(_ apiKey: String) async {
        let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            if trimmed.isEmpty {
                try await translationCredentialStore.deleteAPIKey(
                    providerID: settings.translation.providerID
                )
            } else {
                try await translationCredentialStore.saveAPIKey(
                    trimmed,
                    providerID: settings.translation.providerID
                )
            }
            translationAPIKey = trimmed
            translationConnectionState = .idle
        } catch {
            translationConnectionState = .failed(error.localizedDescription)
        }
    }

    func saveTranslationConfiguration() async {
        do {
            try await settingsStore.save(settings)
        } catch {
            translationConnectionState = .failed("Translation settings could not be saved.")
        }
    }

    func testTranslationConnection() async {
        translationConnectionState = .testing
        do {
            try await translationService.testConnection(settings: settings.translation)
            translationConnectionState = .succeeded
        } catch {
            translationConnectionState = .failed(error.localizedDescription)
        }
    }

    func generateSelectedTranslation() async {
        guard let record = selectedRecord else { return }
        let skill = record.skill
        let sourceMarkdown = markdown
        translationOperationState = .generating(skillID: skill.id)

        do {
            let translation = try await translationService.generate(
                skill: skill,
                markdown: sourceMarkdown,
                settings: settings.translation
            )
            updateRecord(id: skill.id, translation: translation)
            translationOperationState = .succeeded(skillID: skill.id)
        } catch {
            translationOperationState = .failed(
                skillID: skill.id,
                message: error.localizedDescription
            )
        }
    }

    private func updateRecord(id: SkillRecord.ID, translation: SkillTranslation) {
        guard let index = records.firstIndex(where: { $0.id == id }) else { return }
        let record = records[index]
        records[index] = SkillRecord(
            skill: record.skill,
            note: record.note,
            isNoteStale: record.isNoteStale,
            remoteSource: record.remoteSource,
            translation: translation,
            isTranslationStale: translation.contentHash != record.skill.contentHash
        )
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

    func requestInstall(to agentID: String) async {
        guard settings.defaultConflictStrategy == .overwrite else {
            await installSelected(to: agentID, strategy: settings.defaultConflictStrategy)
            return
        }
        pendingOverwrite = .install(agentID)
    }

    func installSelected(to agentID: String, strategy: ConflictStrategy) async {
        guard let record = selectedRecord,
              let target = agentTarget(id: agentID)
        else { return }
        do {
            let result = try await workspaceService.installSkill(
                from: record.skill.path,
                target: target,
                strategy: strategy,
                isSystemSkill: record.skill.isSystem
            )
            operationMessage = result.message
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func requestTargetState(_ installed: Bool, target: AgentTarget) async {
        if installed {
            await requestInstall(to: target.id)
        } else if let record = selectedRecord {
            pendingUninstall = PendingUninstall(
                agentID: target.id,
                skillName: record.skill.name,
                contentHash: record.skill.contentHash,
                isSystemSkill: record.skill.isSystem
            )
        }
    }

    func confirmUninstall(_ pendingUninstall: PendingUninstall) async {
        self.pendingUninstall = nil

        do {
            guard let target = agentTarget(id: pendingUninstall.agentID) else {
                errorMessage = "Install target is no longer available."
                return
            }
            try await workspaceService.uninstallSkill(
                named: pendingUninstall.skillName,
                contentHash: pendingUninstall.contentHash,
                target: target,
                libraryPath: settings.libraryPath,
                allAgentTargets: settings.agentTargets,
                isSystemSkill: pendingUninstall.isSystemSkill
            )
            operationMessage = "Removed from \(target.displayName)."
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

    func openRemoteImport() {
        remoteImport.reset()
        isRemoteImportPresented = true
    }

    func closeRemoteImport() {
        remoteImport.reset()
        isRemoteImportPresented = false
    }

    func confirmRemoteImport() async {
        guard let result = await remoteImport.importSelected(libraryPath: settings.libraryPath) else {
            return
        }
        await refresh()
        if let first = result.copied.first {
            navigationSection = .library
            selectionID = records.first {
                $0.skill.path.standardizedFileURL == first.standardizedFileURL
            }?.id
        }
    }

    func checkSelectedRemoteUpdate() async {
        guard let source = selectedRecord?.remoteSource else { return }
        isCheckingRemoteUpdate = true
        defer { isCheckingRemoteUpdate = false }

        do {
            let update = try await remoteUpdateService.check(source)
            remoteUpdate = update
            if update.status == .upToDate {
                operationMessage = "This Skill is up to date."
            } else {
                isRemoteUpdatePreviewPresented = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func confirmRemoteReplacement() async {
        guard let update = remoteUpdate else { return }

        do {
            let replacement = try await remoteUpdateService.replaceWithRemote(
                update,
                libraryPath: settings.libraryPath
            )
            remoteUpdate = nil
            isRemoteUpdatePreviewPresented = false
            operationMessage = "Updated \(replacement.source.skillName)."
            await refresh()
            selectionID = records.first {
                $0.skill.path.standardizedFileURL == replacement.destination.standardizedFileURL
            }?.id
        } catch {
            errorMessage = error.localizedDescription
        }
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

    func confirmOverwrite(_ pendingOverwrite: PendingOverwrite) async {
        self.pendingOverwrite = nil
        guard case .install(let target) = pendingOverwrite else { return }
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

    func agentTarget(id: String) -> AgentTarget? {
        settings.agentTargets.first { $0.id == id && $0.isEnabled }
    }

    func agentDisplayName(id: String) -> String {
        settings.agentTargets.first { $0.id == id }?.displayName ?? id
    }

    private func isInstalled(_ installation: SkillInstallation, in agentID: String) -> Bool {
        installation.agentIDs.contains(agentID)
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
