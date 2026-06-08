import Foundation

public struct RemoteSkillSource: Codable, Equatable, Sendable {
    public let destination: URL
    public let skillName: String
    public let repositoryURL: URL
    public let owner: String
    public let repository: String
    public let branch: String
    public let repositoryRelativePath: String
    public let requestedMethod: RemoteAcquisitionPreference
    public let actualMethod: RemoteAcquisitionMethod
    public let commit: String
    public let installedContentHash: String
    public var lastCheckedAt: Date?

    public init(
        destination: URL,
        skillName: String,
        repositoryURL: URL,
        owner: String,
        repository: String,
        branch: String,
        repositoryRelativePath: String,
        requestedMethod: RemoteAcquisitionPreference,
        actualMethod: RemoteAcquisitionMethod,
        commit: String,
        installedContentHash: String,
        lastCheckedAt: Date? = nil
    ) {
        self.destination = destination
        self.skillName = skillName
        self.repositoryURL = repositoryURL
        self.owner = owner
        self.repository = repository
        self.branch = branch
        self.repositoryRelativePath = repositoryRelativePath
        self.requestedMethod = requestedMethod
        self.actualMethod = actualMethod
        self.commit = commit
        self.installedContentHash = installedContentHash
        self.lastCheckedAt = lastCheckedAt
    }
}
