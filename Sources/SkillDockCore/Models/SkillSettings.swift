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

public struct SkillSettings: Codable, Equatable, Sendable {
    public var libraryPath: URL
    public var codexPath: URL
    public var claudePath: URL
    public var showSystemSkills: Bool
    public var defaultInstallTargets: [InstallTarget]
    public var defaultConflictStrategy: ConflictStrategy

    public init(
        libraryPath: URL,
        codexPath: URL,
        claudePath: URL,
        showSystemSkills: Bool = true,
        defaultInstallTargets: [InstallTarget] = [.codex, .claude],
        defaultConflictStrategy: ConflictStrategy = .skip
    ) {
        self.libraryPath = libraryPath
        self.codexPath = codexPath
        self.claudePath = claudePath
        self.showSystemSkills = showSystemSkills
        self.defaultInstallTargets = defaultInstallTargets
        self.defaultConflictStrategy = defaultConflictStrategy
    }

    public static func defaults(homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser) -> Self {
        Self(
            libraryPath: homeDirectory.appendingPathComponent("AI-Skills", isDirectory: true),
            codexPath: homeDirectory.appendingPathComponent(".codex/skills", isDirectory: true),
            claudePath: homeDirectory.appendingPathComponent(".claude/skills", isDirectory: true)
        )
    }
}
