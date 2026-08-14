import SkillDockCore

enum AvailableSourceBadge: Equatable {
    case personal
    case plugin
    case system
    case agentCopy

    var title: String {
        switch self {
        case .personal: "Personal"
        case .plugin: "Plugin"
        case .system: "System"
        case .agentCopy: "Agent Copy"
        }
    }
}

enum AvailableSourcePresentation {
    static func badges(for record: SkillRecord) -> [AvailableSourceBadge] {
        var result: [AvailableSourceBadge] = []
        if record.availableSources.contains(.personal) { result.append(.personal) }
        if record.availableSources.contains(.plugin) { result.append(.plugin) }
        if record.availableSources.contains(.system) { result.append(.system) }
        if record.hasInstalledCopy { result.append(.agentCopy) }
        return result
    }
}
