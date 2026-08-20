import SkillDockCore
import SwiftUI

struct SkillListView: View {
    let records: [SkillRecord]
    let agentTargets: [AgentTarget]
    let acceptsImportDrop: Bool
    let showsAgentFilter: Bool
    let showsAvailableSourceFilter: Bool
    @Binding var agentFilter: AgentFilter
    @Binding var availableSourceFilter: AvailableSourceFilter
    @Binding var selectionID: SkillRecord.ID?
    let onImportDrop: ([URL]) -> Void
    @State private var isImportTargeted = false

    var body: some View {
        VStack(spacing: 0) {
            if showsAgentFilter {
                agentFilterBar
            }
            if showsAvailableSourceFilter {
                availableSourceFilterBar
            }

            Group {
                if records.isEmpty {
                    emptyState
                } else {
                    List(records, selection: $selectionID) { record in
                        SkillRowView(
                            record: record,
                            agentTargets: agentTargets,
                            showsAvailableSources: showsAvailableSourceFilter
                        )
                            .tag(record.id)
                    }
                    .navigationTitle("\(records.count) Skills")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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

                ForEach(enabledAgentTargets, id: \.id) { target in
                    Button {
                        agentFilter = .agent(id: target.id)
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
                }
                .font(.system(size: 13))
                .frame(minWidth: 150, alignment: .leading)
            }
            .menuStyle(.button)

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var enabledAgentTargets: [AgentTarget] {
        agentTargets.filter(\.isEnabled)
    }

    private var availableSourceFilterBar: some View {
        HStack {
            Menu {
                ForEach(AvailableSourceFilter.allCases) { filter in
                    Button {
                        availableSourceFilter = filter
                    } label: {
                        Text(filter.title)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text("Source:")
                        .foregroundStyle(.secondary)
                    Text(availableSourceFilter.title)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
                .font(.system(size: 13))
                .frame(minWidth: 150, alignment: .leading)
            }
            .menuStyle(.button)

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private var emptyState: some View {
        if showsAvailableSourceFilter {
            switch availableSourceFilter {
            case .all:
                ContentUnavailableView(
                    "No Available Skills",
                    systemImage: "tray",
                    description: Text("SkillDock currently checks Personal, Plugin, and System sources.")
                )
            case .personal:
                ContentUnavailableView("No Personal Skills", systemImage: "tray")
            case .plugin:
                ContentUnavailableView(
                    "No Plugin Skills",
                    systemImage: "tray",
                    description: Text("SkillDock did not find Plugin Skills from stable plugin metadata.")
                )
            case .system:
                ContentUnavailableView("No System Skills", systemImage: "tray")
            }
        } else {
            ContentUnavailableView(
                "No Skills",
                systemImage: "tray",
                description: Text(
                    acceptsImportDrop
                        ? "Drop one Skill folder here or use Import Skill."
                        : "Refresh or choose another section."
                )
            )
        }
    }

    @ViewBuilder
    private var currentAgentFilterLabel: some View {
        switch agentFilter {
        case .all:
            Text("All Agents")
        case .agent(let id):
            if let target = agentTargets.first(where: { $0.id == id }) {
                HStack(spacing: 6) {
                    AgentMenuLogo(target: target)
                    Text(target.displayName)
                }
            } else {
                Text(id)
            }
        }
    }
}
