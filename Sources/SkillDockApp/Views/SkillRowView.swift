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
                Text(rowDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            HStack(spacing: 5) {
                ForEach(installBadges.visibleTargets, id: \.id) { target in
                    AgentLogo(target: target, installed: true, size: 13)
                        .help("Installed in \(target.displayName)")
                }
                if installBadges.collapsedCount > 0 {
                    Text("+\(installBadges.collapsedCount)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(.quaternary, in: Capsule())
                        .help(installedTargetsTooltip)
                }
            }
            .font(.subheadline)
        }
        .padding(.vertical, VisualMetrics.rowVerticalPadding)
    }

    private var installBadges: SkillRowInstallBadges {
        SkillRowInstallBadges(installedTargets: installedTargets)
    }

    private var installedTargetsTooltip: String {
        let names = installedTargets.map(\.displayName).joined(separator: ", ")
        return names.isEmpty ? "Not installed" : "Installed in \(names)"
    }

    private var installedTargets: [AgentTarget] {
        agentTargets.filter { record.skill.installation.agentIDs.contains($0.id) }
    }

    private var rowDescription: String {
        if !record.isTranslationStale,
           let translated = record.translation?.translatedDescription.nonEmpty {
            return translated
        }
        return record.skill.description ?? record.skill.source.displayName
    }
}

struct SkillRowInstallBadges {
    let visibleTargets: [AgentTarget]
    let collapsedCount: Int

    init(installedTargets: [AgentTarget]) {
        if installedTargets.count <= 2 {
            visibleTargets = installedTargets
            collapsedCount = 0
            return
        }

        var badgeTargets = [AgentTargetID.codex, AgentTargetID.claude].compactMap { id in
            installedTargets.first { $0.id == id }
        }

        if badgeTargets.count < 2 {
            let remainingTargets = installedTargets.filter { target in
                !badgeTargets.contains { $0.id == target.id }
            }
            badgeTargets.append(contentsOf: remainingTargets.prefix(2 - badgeTargets.count))
        }

        visibleTargets = Array(badgeTargets.prefix(2))
        collapsedCount = max(0, installedTargets.count - visibleTargets.count)
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
