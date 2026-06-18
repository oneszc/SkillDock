import SkillDockCore
import SwiftUI

struct SkillDetailView: View {
    @Bindable var model: AppModel
    @State private var tab: DetailTab = .markdown
    @State private var language: TranslationLanguage = .original
    @State private var confirmsRegeneration = false
    @Environment(\.openWindow) private var openWindow
    let record: SkillRecord?

    var body: some View {
        if let record {
            VStack(spacing: 0) {
                detailHeader(record)
                Divider()
                content(for: record)
            }
            .navigationTitle(record.skill.name)
            .task(id: language) {
                guard language == .translated else { return }
                await model.refreshTranslationCredentialStatus()
            }
            .alert("Regenerate Translation?", isPresented: $confirmsRegeneration) {
                Button("Cancel", role: .cancel) {}
                Button("Regenerate") {
                    Task { await model.generateSelectedTranslation() }
                }
            } message: {
                Text("The existing translation will be replaced and additional API usage will be incurred.")
            }
        } else {
            ContentUnavailableView(
                "Select a Skill",
                systemImage: "doc.text.magnifyingglass",
                description: Text("Choose a Skill to view its details.")
            )
        }
    }

    private func detailHeader(_ record: SkillRecord) -> some View {
        VStack(alignment: .leading, spacing: VisualMetrics.sectionSpacing) {
            VStack(alignment: .leading, spacing: VisualMetrics.sectionSpacing) {
                Text(record.skill.name)
                    .font(.system(size: 32, weight: .semibold))
                    .textSelection(.enabled)

                if let description = presentation(for: record).description?.nonEmpty {
                    Text(description)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }

                HStack(spacing: 12) {
                    ForEach(enabledAgentTargets, id: \.id) { target in
                        let installed = isInstalled(target, in: record)

                        Button {
                            guard !record.skill.isSystem, !installed else { return }
                            Task { await model.requestInstall(to: target.id) }
                        } label: {
                            AgentLogo(target: target, installed: installed, size: 18)
                        }
                        .buttonStyle(.plain)
                        .allowsHitTesting(!record.skill.isSystem && !installed)
                        .help(installed ? "Installed in \(target.displayName)" : "Install to \(target.displayName)")
                        .accessibilityLabel("\(target.displayName) installation status")
                        .accessibilityValue(
                            accessibilityValue(installed: installed, isSystem: record.skill.isSystem)
                        )
                    }

                    if record.skill.isSystem {
                        Label("Read-only", systemImage: "lock.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                .labelStyle(.titleAndIcon)
                .font(.body)

                if let source = record.remoteSource {
                    HStack(spacing: 12) {
                        Label("GitHub", systemImage: "network")
                            .foregroundStyle(.secondary)
                        Text("\(source.owner)/\(source.repository)")
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .textSelection(.enabled)
                        if source.branch != "HEAD" {
                            Text(source.branch)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(.quaternary, in: Capsule())
                        }
                        Spacer(minLength: 0)
                        Button {
                            Task { await model.checkSelectedRemoteUpdate() }
                        } label: {
                            Label(
                                model.isCheckingRemoteUpdate ? "Checking" : "Check Update",
                                systemImage: "arrow.clockwise"
                            )
                        }
                        .disabled(model.isCheckingRemoteUpdate)
                    }
                    .font(.callout)
                }
            }
            .frame(maxWidth: VisualMetrics.readableContentWidth, alignment: .leading)

            HStack(spacing: 18) {
                Picker("Detail", selection: $tab) {
                    ForEach(DetailTab.allCases) { item in
                        Label(item.title, systemImage: item.systemImage).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 470)

                Spacer(minLength: 0)

                if tab == .markdown {
                    Picker("Language", selection: $language) {
                        ForEach(TranslationLanguage.allCases) { item in
                            Text(item.title).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .frame(width: 150)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(VisualMetrics.contentPadding)
    }

    private var enabledAgentTargets: [AgentTarget] {
        model.settings.agentTargets.filter(\.isEnabled)
    }

    @ViewBuilder
    private func content(for record: SkillRecord) -> some View {
        switch tab {
        case .markdown:
            translationContent(for: record)
        case .files:
            FilesView(paths: model.filePaths)
        case .install:
            installView(record)
        }
    }

    @ViewBuilder
    private func translationContent(for record: SkillRecord) -> some View {
        let presentation = presentation(for: record)
        switch presentation.state {
        case .original:
            MarkdownPreviewView(markdown: presentation.markdown)
        case .available(let isStale):
            VStack(spacing: 0) {
                HStack {
                    if isStale {
                        Label("The source has changed. This translation may be outdated.", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    } else {
                        Label("AI-generated translation", systemImage: "sparkles")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(isStale ? "Update Translation" : "Regenerate") {
                        confirmsRegeneration = true
                    }
                }
                .font(.callout)
                .padding(.horizontal, VisualMetrics.contentPadding)
                .padding(.vertical, 10)
                .background(.quaternary)
                MarkdownPreviewView(markdown: presentation.markdown)
            }
        case .missingConfiguration, .empty, .generating, .failed:
            TranslationEmptyView(
                state: presentation.state,
                onGenerate: {
                    Task { await model.generateSelectedTranslation() }
                },
                onOpenSettings: {
                    model.settingsSection = .aiTranslation
                    openWindow(id: "settings")
                }
            )
        }
    }

    private func presentation(for record: SkillRecord) -> TranslationPresentation {
        let operation = model.translationOperationState
        let isGenerating: Bool
        let errorMessage: String?
        switch operation {
        case .generating(let skillID) where skillID == record.id:
            isGenerating = true
            errorMessage = nil
        case .failed(let skillID, let message) where skillID == record.id:
            isGenerating = false
            errorMessage = message
        default:
            isGenerating = false
            errorMessage = nil
        }
        return TranslationPresentation(
            record: record,
            originalMarkdown: model.markdown,
            language: language,
            showsMarkdown: tab == .markdown,
            isGenerating: isGenerating,
            errorMessage: errorMessage,
            hasAPIKey: model.translationCredentialStatus == .available
        )
    }

    private func isInstalled(_ target: AgentTarget, in record: SkillRecord) -> Bool {
        record.skill.installation.agentIDs.contains(target.id)
    }

    private func accessibilityValue(installed: Bool, isSystem: Bool) -> String {
        let installationStatus = installed ? "Installed" : "Not installed"
        return isSystem ? "\(installationStatus), system read-only" : installationStatus
    }

    private func installView(_ record: SkillRecord) -> some View {
        Form {
            Section("Install Targets") {
                ForEach(enabledAgentTargets, id: \.id) { target in
                    installRow(
                        installed: isInstalled(target, in: record),
                        target: target,
                        isSystem: record.skill.isSystem
                    )
                }
            }
            if record.skill.isSystem {
                Label("System Skills are read-only.", systemImage: "lock.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    private func installRow(
        installed: Bool,
        target: AgentTarget,
        isSystem: Bool
    ) -> some View {
        Toggle(
            isOn: Binding(
                get: { installed },
                set: { newValue in
                    Task { await model.requestTargetState(newValue, target: target) }
                }
            )
        ) {
            HStack(spacing: 12) {
                AgentLogo(target: target, installed: installed, size: 16)
                Text(target.displayName)
            }
        }
        .toggleStyle(.checkbox)
        .disabled(isSystem)
    }
}

private enum DetailTab: String, CaseIterable, Identifiable {
    case markdown
    case files
    case install

    var id: Self { self }

    var title: String {
        switch self {
        case .markdown: "SKILL.md"
        case .files: "Files"
        case .install: "Install"
        }
    }

    var systemImage: String {
        switch self {
        case .markdown: "doc.text"
        case .files: "folder"
        case .install: "square.and.arrow.down"
        }
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
