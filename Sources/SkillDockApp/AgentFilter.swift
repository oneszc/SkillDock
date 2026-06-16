import SkillDockCore

enum AgentFilter: Equatable {
    case all
    case target(InstallTarget)

    var title: String {
        switch self {
        case .all:
            "All Agents"
        case .target(let target):
            target.displayName
        }
    }
}
