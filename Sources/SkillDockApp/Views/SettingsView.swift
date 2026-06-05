import SkillDockCore
import SwiftUI

struct SettingsView: View {
    @Bindable var model: AppModel

    var body: some View {
        Form {
            Section("Skill Locations") {
                pathField("Library", url: $model.settings.libraryPath)
                pathField("Codex", url: $model.settings.codexPath)
                pathField("Claude", url: $model.settings.claudePath)
            }
            Section("Behavior") {
                Toggle("Show system Skills", isOn: $model.settings.showSystemSkills)
                Picker("Default conflict strategy", selection: $model.settings.defaultConflictStrategy) {
                    ForEach(ConflictStrategy.allCases, id: \.self) {
                        Text($0.rawValue.capitalized).tag($0)
                    }
                }
            }
            HStack {
                Spacer()
                Button("Save Settings") {
                    Task { await model.saveSettings() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .formStyle(.grouped)
        .padding()
        .navigationTitle("Settings")
    }

    private func pathField(_ title: String, url: Binding<URL>) -> some View {
        LabeledContent(title) {
            TextField(
                title,
                text: Binding(
                    get: { url.wrappedValue.path },
                    set: { url.wrappedValue = URL(fileURLWithPath: $0, isDirectory: true) }
                )
            )
            .textFieldStyle(.roundedBorder)
        }
    }
}
