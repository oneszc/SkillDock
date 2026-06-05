import SwiftUI

struct SettingsSidebarView: View {
    var body: some View {
        List(selection: .constant(SettingsSection.general)) {
            Label(SettingsSection.general.title, systemImage: SettingsSection.general.systemImage)
                .font(.body)
                .padding(.vertical, 3)
                .tag(SettingsSection.general)
        }
        .listStyle(.sidebar)
        .navigationTitle("Settings")
    }
}

private enum SettingsSection: Hashable {
    case general

    var title: String { "General" }
    var systemImage: String { "gearshape" }
}
