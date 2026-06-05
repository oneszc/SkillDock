import Foundation

public enum ImportPreviewError: Error, Equatable, Sendable {
    case requiresSingleFolder
    case missingSkillMarkdown
}

public struct ImportPreview: Identifiable, Equatable, Sendable {
    public let id: URL
    public let sourceURL: URL
    public let name: String
    public let description: String?
    public let relativePaths: [String]
    public let fileCount: Int
    public let hasScripts: Bool
    public let hasConflict: Bool
    public var strategy: ConflictStrategy

    public init(
        sourceURL: URL,
        name: String,
        description: String?,
        relativePaths: [String],
        fileCount: Int,
        hasScripts: Bool,
        hasConflict: Bool,
        strategy: ConflictStrategy = .skip
    ) {
        id = sourceURL
        self.sourceURL = sourceURL
        self.name = name
        self.description = description
        self.relativePaths = relativePaths
        self.fileCount = fileCount
        self.hasScripts = hasScripts
        self.hasConflict = hasConflict
        self.strategy = strategy
    }
}
