import SkillDockCore
import SwiftUI

struct SkillRowView: View {
    let record: SkillRecord

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

            VStack(alignment: .trailing, spacing: 4) {
                if record.skill.installation.codex {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .help("Installed in Codex")
                }
                if record.skill.installation.claude {
                    Image(systemName: "checkmark.circle")
                        .foregroundStyle(.secondary)
                        .help("Installed in Claude")
                }
            }
            .font(.subheadline)
        }
        .padding(.vertical, VisualMetrics.rowVerticalPadding)
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
