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

public struct SkillMetadata: Equatable, Sendable {
    public let name: String?
    public let description: String?

    public init(name: String?, description: String?) {
        self.name = name
        self.description = description
    }
}

public struct SkillInstallation: Codable, Equatable, Sendable {
    public var codex: Bool
    public var claude: Bool

    public init(codex: Bool = false, claude: Bool = false) {
        self.codex = codex
        self.claude = claude
    }
}

public struct Skill: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let description: String?
    public let path: URL
    public let source: SkillSource
    public let hasScripts: Bool
    public let isSystem: Bool
    public let isReadOnly: Bool
    public let contentHash: String
    public var installation: SkillInstallation

    public init(
        id: String,
        name: String,
        description: String?,
        path: URL,
        source: SkillSource,
        hasScripts: Bool,
        isSystem: Bool,
        isReadOnly: Bool,
        contentHash: String,
        installation: SkillInstallation = .init()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.path = path
        self.source = source
        self.hasScripts = hasScripts
        self.isSystem = isSystem
        self.isReadOnly = isReadOnly
        self.contentHash = contentHash
        self.installation = installation
    }
}
