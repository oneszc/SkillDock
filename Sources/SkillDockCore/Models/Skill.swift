import Foundation

public enum SkillSource: String, Codable, CaseIterable, Sendable {
    case library
    case codex
    case claude

    public var displayName: String {
        switch self {
        case .library: "Library"
        case .codex: "Codex"
        case .claude: "Claude"
        }
    }
}
