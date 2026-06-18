import SkillDockCore
import SwiftUI

struct AITranslationSettingsView: View {
    @Bindable var model: AppModel
    @State private var apiKey = ""
    @State private var showsAPIKey = false
    @FocusState private var apiKeyFocused: Bool

    var body: some View {
        Form {
            Section("Provider") {
                LabeledContent("Service", value: "DeepSeek")
                Picker("Model", selection: $model.settings.translation.model) {
                    Text("DeepSeek V4 Flash").tag(DeepSeekModel.flash.rawValue)
                    Text("DeepSeek V4 Pro").tag(DeepSeekModel.pro.rawValue)
                }
                .onChange(of: model.settings.translation.model) { _, _ in
                    Task { await model.saveTranslationConfiguration() }
                }
            }

            Section("API Key") {
                LabeledContent("Key") {
                    HStack(spacing: 8) {
                        Group {
                            if showsAPIKey {
                                TextField("DeepSeek API Key", text: $apiKey)
                            } else {
                                SecureField("DeepSeek API Key", text: $apiKey)
                            }
                        }
                        .textFieldStyle(.roundedBorder)
                        .focused($apiKeyFocused)
                        .onSubmit(saveAPIKey)

                        Button {
                            showsAPIKey.toggle()
                        } label: {
                            Image(systemName: showsAPIKey ? "eye.slash" : "eye")
                        }
                        .buttonStyle(.borderless)
                        .help(showsAPIKey ? "Hide API Key" : "Show API Key")
                    }
                    .frame(maxWidth: 420)
                }
                .onChange(of: apiKeyFocused) { _, focused in
                    if !focused { saveAPIKey() }
                }

                HStack {
                    Button {
                        Task {
                            await model.saveTranslationAPIKey(apiKey)
                            await model.testTranslationConnection()
                        }
                    } label: {
                        Label("Test Connection", systemImage: "network")
                    }
                    .disabled(model.translationConnectionState == .testing)

                    connectionStatus
                }
            }

            Section("Privacy") {
                Label {
                    Text("只有在你主动生成译文时，当前 Skill 的 SKILL.md 内容才会发送给 DeepSeek。")
                } icon: {
                    Image(systemName: "hand.raised")
                }
                .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .font(.body)
        .padding(VisualMetrics.contentPadding)
        .task {
            await model.loadTranslationAPIKey()
            apiKey = model.translationAPIKey
        }
    }

    @ViewBuilder
    private var connectionStatus: some View {
        switch model.translationConnectionState {
        case .idle:
            EmptyView()
        case .testing:
            ProgressView()
                .controlSize(.small)
        case .succeeded:
            Label("Connected", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .failed(let message):
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .lineLimit(2)
        }
    }

    private func saveAPIKey() {
        Task { await model.saveTranslationAPIKey(apiKey) }
    }
}
