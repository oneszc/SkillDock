import SwiftUI

struct SettingsWindowView: View {
    @Bindable var model: AppModel
    @State private var selection: SettingsSection = .general

    var body: some View {
        NavigationSplitView {
            List(SettingsSection.allCases, selection: $selection) { section in
                Label(section.title, systemImage: section.systemImage)
                    .tag(section)
            }
            .listStyle(.sidebar)
            .navigationTitle("Settings")
            .navigationSplitViewColumnWidth(min: 200, ideal: 215, max: 240)
        } detail: {
            switch selection {
            case .general:
                SettingsView(model: model)
            }
        }
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
    }
}

enum SettingsSection: String, CaseIterable, Identifiable {
    case general

    var id: Self { self }

    var title: String {
        switch self {
        case .general: "General"
        }
    }

    var systemImage: String {
        switch self {
        case .general: "gearshape"
        }
    }
}
