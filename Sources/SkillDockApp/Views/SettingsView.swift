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
            }
            Section("Agent Targets") {
                ForEach($model.settings.agentTargets) { $target in
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle(isOn: $target.isEnabled) {
                            HStack(spacing: 10) {
                                AgentLogo(target: target, installed: true, size: 16)
                                Text(target.displayName)
                            }
                        }
                        .onChange(of: target.isEnabled) { _, _ in
                            Task { await model.saveSettings() }
                        }

                        PathField(title: "Path", url: $target.path) {
                            Task { await model.saveSettings() }
                        }
                        .disabled(!target.isEnabled)
                    }
                    .padding(.vertical, 6)
                }

                if hasMissingSuggestedAgents {
                    Button("Add Suggested Agents") {
                        addSuggestedAgents()
                    }
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
    }

    private var hasMissingSuggestedAgents: Bool {
        let existingIDs = Set(model.settings.agentTargets.map(\.id))
        return suggestedAgentTargets.contains { !existingIDs.contains($0.id) }
    }

    private var suggestedAgentTargets: [AgentTarget] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return [
            AgentTarget(
                id: AgentTargetID.grok,
                displayName: "Grok",
                path: home.appendingPathComponent("Grok-Skills", isDirectory: true),
                isEnabled: false,
                logoAssetName: "grok"
            ),
            AgentTarget(
                id: AgentTargetID.gemini,
                displayName: "Gemini",
                path: home.appendingPathComponent("Gemini-Skills", isDirectory: true),
                isEnabled: false,
                logoAssetName: "gemini"
            ),
            AgentTarget(
                id: AgentTargetID.openCode,
                displayName: "OpenCode",
                path: home.appendingPathComponent("OpenCode-Skills", isDirectory: true),
                isEnabled: false,
                logoAssetName: "opencode"
            ),
            AgentTarget(
                id: AgentTargetID.antigravity,
                displayName: "Antigravity",
                path: home.appendingPathComponent("Antigravity-Skills", isDirectory: true),
                isEnabled: false,
                logoAssetName: "antigravity"
            ),
            AgentTarget(
                id: AgentTargetID.hermes,
                displayName: "Hermes",
                path: home.appendingPathComponent("Hermes-Skills", isDirectory: true),
                isEnabled: false,
                logoAssetName: "hermesagent"
            )
        ]
    }

    private func addSuggestedAgents() {
        let existingIDs = Set(model.settings.agentTargets.map(\.id))
        model.settings.agentTargets.append(
            contentsOf: suggestedAgentTargets.filter { !existingIDs.contains($0.id) }
        )
        Task { await model.saveSettings() }
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
