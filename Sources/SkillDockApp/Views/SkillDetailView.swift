import SkillDockCore
import SwiftUI

struct SkillDetailView: View {
    let record: SkillRecord?

    var body: some View {
        if let record {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(record.note?.chineseName.nonEmpty ?? record.skill.name)
                            .font(.title2.weight(.semibold))
                        Text(record.skill.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if let description = record.note?.chineseDescription.nonEmpty
                        ?? record.skill.description {
                        Text(description)
                            .textSelection(.enabled)
                    }

                    LabeledContent("Source", value: record.skill.source.displayName)
                    LabeledContent("Path", value: record.skill.path.path)
                    LabeledContent("Scripts", value: record.skill.hasScripts ? "Review recommended" : "None")
                    LabeledContent("Codex", value: record.skill.installation.codex ? "Installed" : "Not installed")
                    LabeledContent("Claude", value: record.skill.installation.claude ? "Installed" : "Not installed")

                    if record.isNoteStale {
                        Label("Chinese understanding may need an update.", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                    }
                }
                .padding(24)
                .frame(maxWidth: 720, alignment: .leading)
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
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
