import SkillDockCore
import SwiftUI

struct SettingsView: View {
    @Bindable var model: AppModel

    var body: some View {
        Form {
            Section {
                AppearanceModePicker(
                    selection: model.settings.appearanceMode,
                    onSelect: { mode in
                        Task { await model.selectAppearanceMode(mode) }
                    }
                )
            }
            Section("Skill Locations") {
                PathField(title: "Library", url: $model.settings.libraryPath) {
                    Task { await model.saveSettings() }
                }
                PathField(title: "Codex", url: $model.settings.codexPath) {
                    Task { await model.saveSettings() }
                }
                PathField(title: "Claude", url: $model.settings.claudePath) {
                    Task { await model.saveSettings() }
                }
            }
            Section("Behavior") {
                Toggle("Show system Skills", isOn: $model.settings.showSystemSkills)
                    .onChange(of: model.settings.showSystemSkills) { _, _ in
                        Task { await model.saveSettings() }
                    }
                Picker("Default conflict strategy", selection: $model.settings.defaultConflictStrategy) {
                    ForEach(ConflictStrategy.allCases, id: \.self) {
                        Text($0.rawValue.capitalized).tag($0)
                    }
                }
                .onChange(of: model.settings.defaultConflictStrategy) { _, _ in
                    Task { await model.saveSettings() }
                }
            }
        }
        .formStyle(.grouped)
        .font(.body)
        .padding(VisualMetrics.contentPadding)
        .navigationTitle("General")
    }
}

private struct PathField: View {
    let title: String
    @Binding var url: URL
    let onCommit: () -> Void

    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        LabeledContent(title) {
            TextField(title, text: $text)
                .textFieldStyle(.roundedBorder)
                .labelsHidden()
                .fixedSize(horizontal: true, vertical: false)
                .focused($isFocused)
                .onSubmit(commit)
                .onChange(of: isFocused) { _, focused in
                    if !focused { commit() }
                }
        }
        .onAppear { text = url.path }
        .onChange(of: url) { _, newValue in
            if !isFocused { text = newValue.path }
        }
    }

    private func commit() {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        let newURL = URL(fileURLWithPath: trimmed, isDirectory: true)
        guard newURL != url else { return }
        url = newURL
        onCommit()
    }
}
