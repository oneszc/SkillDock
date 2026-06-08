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

public struct RemoteRepository: Sendable {
    public let reference: GitHubRepositoryReference
    public let localRoot: URL
    public let method: RemoteAcquisitionMethod
    public let commit: String
    public let requiresCleanup: Bool

    public init(
        reference: GitHubRepositoryReference,
        localRoot: URL,
        method: RemoteAcquisitionMethod,
        commit: String,
        requiresCleanup: Bool
    ) {
        self.reference = reference
        self.localRoot = localRoot
        self.method = method
        self.commit = commit
        self.requiresCleanup = requiresCleanup
    }
}
