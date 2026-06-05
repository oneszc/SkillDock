import SkillDockCore
import SwiftUI

struct SkillDetailView: View {
    @Bindable var model: AppModel
    @State private var tab: DetailTab = .overview
    let record: SkillRecord?

    var body: some View {
        if let record {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(record.note?.chineseName.nonEmpty ?? record.skill.name)
                        .font(.title2.weight(.semibold))
                    Text(record.note?.chineseDescription.nonEmpty ?? record.skill.description ?? record.skill.name)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    Picker("Detail", selection: $tab) {
                        ForEach(DetailTab.allCases) { item in
                            Label(item.title, systemImage: item.systemImage).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(20)

                Divider()

                switch tab {
                case .overview:
                    OverviewView(record: record)
                case .markdown:
                    MarkdownPreviewView(markdown: model.markdown)
                case .files:
                    FilesView(paths: model.filePaths)
                case .notes:
                    NotesEditorView(record: record, onSave: model.saveNote)
                case .install:
                    installView(record)
                }
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
    case overview
    case markdown
    case files
    case notes
    case install

    var id: Self { self }

    var title: String {
        switch self {
        case .overview: "Overview"
        case .markdown: "SKILL.md"
        case .files: "Files"
        case .notes: "Chinese Notes"
        case .install: "Install"
        }
    }

    var systemImage: String {
        switch self {
        case .overview: "info.circle"
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
