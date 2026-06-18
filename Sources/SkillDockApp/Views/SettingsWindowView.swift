import SwiftUI

struct SettingsWindowView: View {
    @Bindable var model: AppModel
    var body: some View {
        NavigationSplitView {
            List(SettingsSection.allCases, selection: $model.settingsSection) { section in
                Label(section.title, systemImage: section.systemImage)
                    .tag(section)
            }
            .listStyle(.sidebar)
            .navigationTitle("Settings")
            .navigationSplitViewColumnWidth(min: 200, ideal: 215, max: 240)
        } detail: {
            switch model.settingsSection {
            case .general:
                SettingsView(model: model)
            case .aiTranslation:
                AITranslationSettingsView(model: model)
            }
        }
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
    }
}

enum SettingsSection: String, CaseIterable, Identifiable {
    case general
    case aiTranslation

    var id: Self { self }

    var title: String {
        switch self {
        case .general: "General"
        case .aiTranslation: "AI Translation"
        }
    }

    var systemImage: String {
        switch self {
        case .general: "gearshape"
        case .aiTranslation: "character.book.closed"
        }
    }
}
