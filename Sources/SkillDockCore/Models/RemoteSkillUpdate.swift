import Foundation

public enum RemoteUpdateStatus: Equatable, Sendable {
    case upToDate
    case updateAvailable
    case localModified
}

public struct RemoteSkillUpdate: Equatable, Sendable {
    public let source: RemoteSkillSource
    public let status: RemoteUpdateStatus
    public let currentContentHash: String
    public let remoteContentHash: String
    public let currentCommit: String
    public let remoteCommit: String
    public let addedFiles: [String]
    public let modifiedFiles: [String]
    public let removedFiles: [String]

    public init(
        source: RemoteSkillSource,
        status: RemoteUpdateStatus,
        currentContentHash: String,
        remoteContentHash: String,
        currentCommit: String,
        remoteCommit: String,
        addedFiles: [String] = [],
        modifiedFiles: [String] = [],
        removedFiles: [String] = []
    ) {
        self.source = source
        self.status = status
        self.currentContentHash = currentContentHash
        self.remoteContentHash = remoteContentHash
        self.currentCommit = currentCommit
        self.remoteCommit = remoteCommit
        self.addedFiles = addedFiles
        self.modifiedFiles = modifiedFiles
        self.removedFiles = removedFiles
    }
}

public struct RemoteSkillReplacement: Equatable, Sendable {
    public let destination: URL
    public let source: RemoteSkillSource

    public init(destination: URL, source: RemoteSkillSource) {
        self.destination = destination
        self.source = source
    }
}

public enum RemoteUpdateError: Error, Equatable, Sendable {
    case localModifiedSkill
}

extension RemoteUpdateError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .localModifiedSkill:
            "This Skill has local changes. Review it before replacing."
        }
    }
}
