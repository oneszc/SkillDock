import Foundation

public enum AvailableSkillSource: String, Codable, CaseIterable, Hashable, Sendable {
    case personal
    case system

    public var displayName: String {
        switch self {
        case .personal:
            "Personal"
        case .system:
            "System"
        }
    }
}

public enum SkillSource: Codable, Equatable, Hashable, Sendable {
    case library
    case agent(String)
    case available(AvailableSkillSource)

    public static let codex = SkillSource.agent(AgentTargetID.codex)
    public static let claude = SkillSource.agent(AgentTargetID.claude)

    public var displayName: String {
        switch self {
        case .library:
            "Library"
        case .agent(let id):
            switch id {
            case AgentTargetID.codex:
                "Codex"
            case AgentTargetID.claude:
                "Claude"
            default:
                id
            }
        case .available(let source):
            source.displayName
        }
    }

    public var rawValue: String {
        switch self {
        case .library:
            "library"
        case .agent(let id):
            id
        case .available(let source):
            "available:\(source.rawValue)"
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        if value == "library" {
            self = .library
        } else if value.hasPrefix("available:") {
            guard let source = AvailableSkillSource(
                rawValue: String(value.dropFirst("available:".count))
            ) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Unknown available Skill source: \(value)"
                )
            }
            self = .available(source)
        } else {
            self = .agent(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
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
    public var agentIDs: Set<String>

    public init(agentIDs: Set<String> = []) {
        self.agentIDs = agentIDs
    }

    public init(codex: Bool = false, claude: Bool = false) {
        var ids = Set<String>()
        if codex { ids.insert(AgentTargetID.codex) }
        if claude { ids.insert(AgentTargetID.claude) }
        self.agentIDs = ids
    }

    public var codex: Bool {
        get { agentIDs.contains(AgentTargetID.codex) }
        set {
            if newValue {
                agentIDs.insert(AgentTargetID.codex)
            } else {
                agentIDs.remove(AgentTargetID.codex)
            }
        }
    }

    public var claude: Bool {
        get { agentIDs.contains(AgentTargetID.claude) }
        set {
            if newValue {
                agentIDs.insert(AgentTargetID.claude)
            } else {
                agentIDs.remove(AgentTargetID.claude)
            }
        }
    }
}

public struct SkillPhysicalCopy: Codable, Equatable, Sendable {
    public let source: SkillSource
    public let path: URL
    public let isSystem: Bool
    public let isReadOnly: Bool
    public let contentHash: String

    public init(
        source: SkillSource,
        path: URL,
        isSystem: Bool,
        isReadOnly: Bool,
        contentHash: String
    ) {
        self.source = source
        self.path = path
        self.isSystem = isSystem
        self.isReadOnly = isReadOnly
        self.contentHash = contentHash
    }
}

public extension SkillPhysicalCopy {
    var availableSource: AvailableSkillSource? {
        guard case .available(let source) = source else { return nil }
        return source
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

public extension Skill {
    var physicalCopy: SkillPhysicalCopy {
        SkillPhysicalCopy(
            source: source,
            path: path,
            isSystem: isSystem,
            isReadOnly: isReadOnly,
            contentHash: contentHash
        )
    }
}
