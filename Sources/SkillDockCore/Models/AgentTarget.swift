import Foundation

public struct AgentTarget: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public var displayName: String
    public var path: URL
    public var isEnabled: Bool
    public var logoAssetName: String?
    public var supportsSystemSkills: Bool

    public init(
        id: String,
        displayName: String,
        path: URL,
        isEnabled: Bool,
        logoAssetName: String? = nil,
        supportsSystemSkills: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.path = path
        self.isEnabled = isEnabled
        self.logoAssetName = logoAssetName
        self.supportsSystemSkills = supportsSystemSkills
    }
}

public enum AgentTargetID {
    public static let codex = "codex"
    public static let claude = "claude"
    public static let grok = "grok"
    public static let gemini = "gemini"
    public static let openCode = "opencode"
    public static let antigravity = "antigravity"
    public static let hermes = "hermes"

    public static func defaultLogoAssetName(for id: String) -> String? {
        switch id {
        case codex:
            "codex"
        case claude:
            "claude"
        case grok:
            "grok"
        case gemini:
            "gemini"
        case openCode:
            "opencode"
        case antigravity:
            "antigravity"
        case hermes:
            "hermesagent"
        default:
            nil
        }
    }
}

public extension AgentTarget {
    static func codex(homeDirectory: URL) -> Self {
        AgentTarget(
            id: AgentTargetID.codex,
            displayName: "Codex",
            path: homeDirectory.appendingPathComponent(".codex/skills", isDirectory: true),
            isEnabled: true,
            logoAssetName: "codex",
            supportsSystemSkills: true
        )
    }

    static func claude(homeDirectory: URL) -> Self {
        AgentTarget(
            id: AgentTargetID.claude,
            displayName: "Claude",
            path: homeDirectory.appendingPathComponent(".claude/skills", isDirectory: true),
            isEnabled: true,
            logoAssetName: "claude"
        )
    }
}
