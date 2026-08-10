import SkillDockCore

enum AvailableSourceFilter: String, CaseIterable, Identifiable {
    case all
    case personal
    case system

    var id: Self { self }

    var title: String {
        switch self {
        case .all: "All Sources"
        case .personal: "Personal"
        case .system: "System"
        }
    }

    var source: AvailableSkillSource? {
        switch self {
        case .all: nil
        case .personal: .personal
        case .system: .system
        }
    }
}
