import SkillDockCore
import SwiftUI

struct SkillRowView: View {
    let record: SkillRecord

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: record.skill.isSystem ? "lock.doc" : "doc.text")
                .foregroundStyle(record.skill.isSystem ? Color.secondary : Color.accentColor)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 3) {
                Text(record.note?.chineseName.nonEmpty ?? record.skill.name)
                    .font(.body)
                    .lineLimit(1)
                Text(record.note?.chineseDescription.nonEmpty ?? record.skill.description ?? record.skill.source.displayName)
                    .font(.caption)
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
            .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
