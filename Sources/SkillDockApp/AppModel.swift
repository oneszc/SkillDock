import Foundation
import Observation
import SkillDockCore

@MainActor
@Observable
final class AppModel {
    var records: [SkillRecord] = []
    var selectionID: SkillRecord.ID?
    var navigationSection: NavigationSection = .library
    var searchQuery = ""
    var settings: SkillSettings = .defaults()
    var isRefreshing = false
    var errorMessage: String?

    private let settingsStore: SettingsStore
    private let libraryService: SkillLibraryService
    private let search = SkillSearch()

    init(
        settingsStore: SettingsStore = .init(),
        libraryService: SkillLibraryService = .init()
    ) {
        self.settingsStore = settingsStore
        self.libraryService = libraryService
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
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func preserveOrSelectFirstRecord() {
        guard records.contains(where: { $0.id == selectionID }) else {
            selectionID = filteredRecords.first?.id
            return
        }
    }
}
