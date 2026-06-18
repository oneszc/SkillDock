import Foundation

public enum InstallTarget: String, Codable, CaseIterable, Sendable {
    case codex
    case claude
}

public enum ConflictStrategy: String, Codable, CaseIterable, Sendable {
    case skip
    case overwrite
    case rename
}

public enum AppearanceMode: String, Codable, CaseIterable, Sendable {
    case system
    case light
    case dark
}

public struct SkillSettings: Codable, Equatable, Sendable {
    public var libraryPath: URL
    public var codexPath: URL
    public var claudePath: URL
    public var agentTargets: [AgentTarget]
    public var showSystemSkills: Bool
    public var defaultInstallTargets: [InstallTarget]
    public var defaultConflictStrategy: ConflictStrategy
    public var appearanceMode: AppearanceMode
    public var translation: TranslationSettings

    public init(
        libraryPath: URL,
        codexPath: URL,
        claudePath: URL,
        agentTargets: [AgentTarget]? = nil,
        showSystemSkills: Bool = true,
        defaultInstallTargets: [InstallTarget] = [.codex, .claude],
        defaultConflictStrategy: ConflictStrategy = .skip,
        appearanceMode: AppearanceMode = .system,
        translation: TranslationSettings = .init()
    ) {
        self.libraryPath = libraryPath
        self.codexPath = codexPath
        self.claudePath = claudePath
        self.agentTargets = Self.normalizedAgentTargets(agentTargets ?? [
            AgentTarget(
                id: AgentTargetID.codex,
                displayName: "Codex",
                path: codexPath,
                isEnabled: true,
                logoAssetName: "codex",
                supportsSystemSkills: true
            ),
            AgentTarget(
                id: AgentTargetID.claude,
                displayName: "Claude",
                path: claudePath,
                isEnabled: true,
                logoAssetName: "claude"
            )
        ])
        self.showSystemSkills = showSystemSkills
        self.defaultInstallTargets = defaultInstallTargets
        self.defaultConflictStrategy = defaultConflictStrategy
        self.appearanceMode = appearanceMode
        self.translation = translation
    }

    public static func defaults(homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser) -> Self {
        Self(
            libraryPath: homeDirectory.appendingPathComponent("AI-Skills", isDirectory: true),
            codexPath: homeDirectory.appendingPathComponent(".codex/skills", isDirectory: true),
            claudePath: homeDirectory.appendingPathComponent(".claude/skills", isDirectory: true),
            agentTargets: [
                .codex(homeDirectory: homeDirectory),
                .claude(homeDirectory: homeDirectory)
            ]
        )
    }

    private enum CodingKeys: String, CodingKey {
        case libraryPath
        case codexPath
        case claudePath
        case agentTargets
        case showSystemSkills
        case defaultInstallTargets
        case defaultConflictStrategy
        case appearanceMode
        case translation
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        libraryPath = try container.decode(URL.self, forKey: .libraryPath)
        codexPath = try container.decode(URL.self, forKey: .codexPath)
        claudePath = try container.decode(URL.self, forKey: .claudePath)
        agentTargets = Self.normalizedAgentTargets(
            try container.decodeIfPresent([AgentTarget].self, forKey: .agentTargets)
                ?? [
                    AgentTarget(
                        id: AgentTargetID.codex,
                        displayName: "Codex",
                        path: codexPath,
                        isEnabled: true,
                        logoAssetName: "codex",
                        supportsSystemSkills: true
                    ),
                    AgentTarget(
                        id: AgentTargetID.claude,
                        displayName: "Claude",
                        path: claudePath,
                        isEnabled: true,
                        logoAssetName: "claude"
                    )
                ]
        )
        showSystemSkills = try container.decode(Bool.self, forKey: .showSystemSkills)
        defaultInstallTargets = try container.decode([InstallTarget].self, forKey: .defaultInstallTargets)
        defaultConflictStrategy = try container.decode(ConflictStrategy.self, forKey: .defaultConflictStrategy)
        appearanceMode = try container.decodeIfPresent(AppearanceMode.self, forKey: .appearanceMode) ?? .system
        translation = try container.decodeIfPresent(TranslationSettings.self, forKey: .translation) ?? .init()
    }

    private static func normalizedAgentTargets(_ targets: [AgentTarget]) -> [AgentTarget] {
        targets.map { target in
            guard target.logoAssetName == nil,
                  let logoAssetName = AgentTargetID.defaultLogoAssetName(for: target.id)
            else {
                return target
            }
            var normalized = target
            normalized.logoAssetName = logoAssetName
            return normalized
        }
    }
}
