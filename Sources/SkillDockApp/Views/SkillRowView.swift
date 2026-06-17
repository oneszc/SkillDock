import SkillDockCore
import SwiftUI

struct SkillRowView: View {
    let record: SkillRecord
    let agentTargets: [AgentTarget]

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: record.skill.isSystem ? "lock.doc" : "doc.text")
                .font(.title3)
                .foregroundStyle(record.skill.isSystem ? Color.secondary : Color.accentColor)
                .frame(width: VisualMetrics.rowIconSize)

            VStack(alignment: .leading, spacing: 5) {
                Text(record.skill.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(record.note?.chineseDescription.nonEmpty ?? record.skill.description ?? record.skill.source.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            HStack(spacing: 5) {
                ForEach(installedTargets, id: \.id) { target in
                    AgentLogo(target: target, installed: true, size: 13)
                        .help("Installed in \(target.displayName)")
                }
            }
            .font(.subheadline)
        }
        .padding(.vertical, VisualMetrics.rowVerticalPadding)
    }

    private var installedTargets: [AgentTarget] {
        agentTargets.filter { record.skill.installation.agentIDs.contains($0.id) }
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
