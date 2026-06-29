import Foundation

public enum RemoteAcquisitionPreference: String, Codable, CaseIterable, Sendable {
    case automatic
    case gitClone
    case zip
}

public enum RemoteAcquisitionMethod: String, Codable, Sendable {
    case gitClone
    case zip
}

public enum RemotePluginManifestKind: String, Codable, Equatable, Hashable, Sendable {
    case codex
    case claude

    public var displayName: String {
        switch self {
        case .codex: "Codex"
        case .claude: "Claude Code"
        }
    }
}

public struct RemoteRepository: Sendable {
    public let reference: GitHubRepositoryReference
    public let localRoot: URL
    public let method: RemoteAcquisitionMethod
    public let commit: String
    public let requiresCleanup: Bool
    public let pluginManifestKinds: Set<RemotePluginManifestKind>

    public init(
        reference: GitHubRepositoryReference,
        localRoot: URL,
        method: RemoteAcquisitionMethod,
        commit: String,
        requiresCleanup: Bool,
        pluginManifestKinds: Set<RemotePluginManifestKind> = []
    ) {
        self.reference = reference
        self.localRoot = localRoot
        self.method = method
        self.commit = commit
        self.requiresCleanup = requiresCleanup
        self.pluginManifestKinds = pluginManifestKinds
    }
}
