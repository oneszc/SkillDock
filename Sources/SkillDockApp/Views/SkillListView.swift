import SkillDockCore
import SwiftUI

struct SkillListView: View {
    let records: [SkillRecord]
    let acceptsImportDrop: Bool
    let showsAgentFilter: Bool
    @Binding var agentFilter: AgentFilter
    @Binding var selectionID: SkillRecord.ID?
    let onImportDrop: ([URL]) -> Void
    @State private var isImportTargeted = false

    var body: some View {
        VStack(spacing: 0) {
            if showsAgentFilter {
                agentFilterBar
                Divider()
            }

            Group {
                if records.isEmpty {
                    ContentUnavailableView(
                        "No Skills",
                        systemImage: "tray",
                        description: Text(
                            acceptsImportDrop
                                ? "Drop one Skill folder here or use Import Skill."
                                : "Refresh or choose another section."
                        )
                    )
                } else {
                    List(records, selection: $selectionID) { record in
                        SkillRowView(record: record)
                            .tag(record.id)
                    }
                    .navigationTitle("\(records.count) Skills")
                }
            }
        }
        .dropDestination(for: URL.self) { urls, _ in
            guard acceptsImportDrop else { return false }
            onImportDrop(urls)
            return urls.count == 1
        } isTargeted: { targeted in
            isImportTargeted = acceptsImportDrop && targeted
        }
        .overlay {
            if isImportTargeted {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(
                        Color.accentColor,
                        style: StrokeStyle(lineWidth: 2, dash: [6])
                    )
                    .padding(6)
                    .allowsHitTesting(false)
            }
        }
    }

    private var agentFilterBar: some View {
        HStack {
            Menu {
                Button {
                    agentFilter = .all
                } label: {
                    Label("All Agents", systemImage: "circle.grid.2x2")
                }

                Divider()

                ForEach(InstallTarget.allCases, id: \.self) { target in
                    Button {
                        agentFilter = .target(target)
                    } label: {
                        HStack {
                            AgentLogo(target: target, installed: true, size: 13)
                            Text(target.displayName)
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text("Agent:")
                        .foregroundStyle(.secondary)
                    currentAgentFilterLabel
                        .fontWeight(.medium)
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .font(.system(size: 13))
                .frame(minWidth: 170, alignment: .leading)
            }
            .menuIndicator(.hidden)
            .menuStyle(.button)

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private var currentAgentFilterLabel: some View {
        switch agentFilter {
        case .all:
            Text("All Agents")
        case .target(let target):
            HStack(spacing: 6) {
                AgentLogo(target: target, installed: true, size: 13)
                Text(target.displayName)
            }
        }
    }
}
