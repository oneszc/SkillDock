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
        VStack(alignment: .leading, spacing: 14) {
            Text(record.skill.name)
                .font(.largeTitle.weight(.semibold))
                .textSelection(.enabled)

            if let englishDescription = record.skill.description?.nonEmpty {
                Text(englishDescription)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }

            if let chineseDescription = record.note?.chineseDescription.nonEmpty {
                Text(chineseDescription)
                    .font(.body)
                    .textSelection(.enabled)
            }

            HStack(spacing: 12) {
                Label(record.skill.source.displayName, systemImage: "folder")

                if record.skill.installation.codex {
                    Label("Codex", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
                if record.skill.installation.claude {
                    Label("Claude", systemImage: "checkmark.circle")
                        .foregroundStyle(.secondary)
                }
                if record.skill.isSystem {
                    Label("Read-only", systemImage: "lock.fill")
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: model.revealSelectedInFinder) {
                    Label("Reveal in Finder", systemImage: "folder")
                }
                Button(action: model.copySelectedPath) {
                    Label("Copy Path", systemImage: "doc.on.doc")
                }
            }
            .labelStyle(.titleAndIcon)
            .font(.subheadline)

            Picker("Detail", selection: $tab) {
                ForEach(DetailTab.allCases) { item in
                    Label(item.title, systemImage: item.systemImage).tag(item)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(24)
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

    private func installView(_ record: SkillRecord) -> some View {
        Form {
            Section("Install Targets") {
                installRow(
                    title: "Codex",
                    installed: record.skill.installation.codex,
                    target: .codex
                )
                installRow(
                    title: "Claude",
                    installed: record.skill.installation.claude,
                    target: .claude
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
        title: String,
        installed: Bool,
        target: InstallTarget
    ) -> some View {
        HStack {
            Label(
                title,
                systemImage: installed ? "checkmark.circle.fill" : "circle"
            )
            Spacer()
            Button(installed ? "Reinstall" : "Install") {
                Task { await model.requestInstall(to: target) }
            }
            .disabled(record?.skill.isSystem == true)
        }
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
