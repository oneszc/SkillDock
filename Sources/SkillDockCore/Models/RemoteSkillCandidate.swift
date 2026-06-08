import Foundation

public struct RemoteSkillCandidate: Identifiable, Equatable, Sendable {
    public let id: String
    public let sourceURL: URL
    public let repositoryRelativePath: String
    public let name: String
    public let description: String?
    public let contentHash: String
    public let relativePaths: [String]
    public let fileCount: Int
    public let hasScripts: Bool
    public let hasConflict: Bool
    public var isSelected: Bool
    public var strategy: ConflictStrategy

    public init(
        sourceURL: URL,
        repositoryRelativePath: String,
        name: String,
        description: String?,
        contentHash: String,
        relativePaths: [String],
        fileCount: Int,
        hasScripts: Bool,
        hasConflict: Bool,
        isSelected: Bool,
        strategy: ConflictStrategy = .skip
    ) {
        id = repositoryRelativePath
        self.sourceURL = sourceURL
        self.repositoryRelativePath = repositoryRelativePath
        self.name = name
        self.description = description
        self.contentHash = contentHash
        self.relativePaths = relativePaths
        self.fileCount = fileCount
        self.hasScripts = hasScripts
        self.hasConflict = hasConflict
        self.isSelected = isSelected
        self.strategy = strategy
    }
}
