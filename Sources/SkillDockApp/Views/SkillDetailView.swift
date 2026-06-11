import SkillDockCore
import SwiftUI

struct SkillDetailView: View {
    @Bindable var model: AppModel
    @State private var tab: DetailTab = .markdown
    let record: SkillRecord?

    var body: some View {
        if let record {
            VStack(spacing: 0) {
                detailHeader(record)
                Divider()
                content(for: record)
            }
            .navigationTitle(record.skill.name)
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
            Text(record.skill.name)
                .font(.system(size: 32, weight: .semibold))
                .textSelection(.enabled)

            if let englishDescription = record.skill.description?.nonEmpty {
                Text(englishDescription)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }

            if let chineseDescription = record.note?.chineseDescription.nonEmpty {
                Text(chineseDescription)
                    .font(.title3)
                    .textSelection(.enabled)
            }

            HStack(spacing: 12) {
                ForEach(InstallTarget.allCases, id: \.self) { target in
                    let installed = isInstalled(target, in: record)

                    Button {
                        guard !installed else { return }
                        Task { await model.requestInstall(to: target) }
                    } label: {
                        AgentLogo(target: target, installed: installed, size: 22)
                    }
                    .buttonStyle(.plain)
                    .disabled(record.skill.isSystem || installed)
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

            Picker("Detail", selection: $tab) {
                ForEach(DetailTab.allCases) { item in
                    Label(item.title, systemImage: item.systemImage).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
        .frame(maxWidth: VisualMetrics.readableContentWidth, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(VisualMetrics.contentPadding)
    }

    @ViewBuilder
    private func content(for record: SkillRecord) -> some View {
        switch tab {
        case .markdown:
            MarkdownPreviewView(markdown: model.markdown)
        case .files:
            FilesView(paths: model.filePaths)
        case .notes:
            NotesEditorView(model: model)
        case .install:
            installView(record)
        }
    }

    private func isInstalled(_ target: InstallTarget, in record: SkillRecord) -> Bool {
        switch target {
        case .codex:
            record.skill.installation.codex
        case .claude:
            record.skill.installation.claude
        }
    }

    private func accessibilityValue(installed: Bool, isSystem: Bool) -> String {
        let installationStatus = installed ? "Installed" : "Not installed"
        return isSystem ? "\(installationStatus), system read-only" : installationStatus
    }

    private func installView(_ record: SkillRecord) -> some View {
        Form {
            Section("Install Targets") {
                installRow(
                    installed: record.skill.installation.codex,
                    target: .codex,
                    isSystem: record.skill.isSystem
                )
                installRow(
                    installed: record.skill.installation.claude,
                    target: .claude,
                    isSystem: record.skill.isSystem
                )
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
        target: InstallTarget,
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
                AgentLogo(target: target, size: 20)
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
    case notes
    case install

    var id: Self { self }

    var title: String {
        switch self {
        case .markdown: "SKILL.md"
        case .files: "Files"
        case .notes: "Chinese Notes"
        case .install: "Install"
        }
    }

    var systemImage: String {
        switch self {
        case .markdown: "doc.text"
        case .files: "folder"
        case .notes: "character.book.closed"
        case .install: "square.and.arrow.down"
        }
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
