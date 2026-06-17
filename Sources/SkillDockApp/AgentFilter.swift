import SkillDockCore

enum AgentFilter: Equatable {
    case all
    case agent(id: String)

    func title(in targets: [AgentTarget]) -> String {
        switch self {
        case .all:
            "All Agents"
        case .agent(let id):
            targets.first { $0.id == id }?.displayName ?? id
        }
    }
}
