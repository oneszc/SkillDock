import Foundation

public enum RiskLevel: String, Codable, CaseIterable, Sendable {
    case low
    case medium
    case high
    case unknown
}

public struct SkillNoteKey: Hashable, Codable, Sendable {
    public let name: String
    public let source: SkillSource
    public let contentHash: String

    public init(name: String, source: SkillSource, contentHash: String) {
        self.name = name
        self.source = source
        self.contentHash = contentHash
    }
}

public struct SkillNote: Codable, Equatable, Sendable {
    public let key: SkillNoteKey
    public var chineseName: String
    public var chineseDescription: String
    public var tags: [String]
    public var useCases: [String]
    public var riskLevel: RiskLevel
    public var riskNote: String
    public var usageNote: String
    public var updatedAt: Date

    public init(
        key: SkillNoteKey,
        chineseName: String,
        chineseDescription: String,
        tags: [String],
        useCases: [String],
        riskLevel: RiskLevel,
        riskNote: String,
        usageNote: String,
        updatedAt: Date
    ) {
        self.key = key
        self.chineseName = chineseName
        self.chineseDescription = chineseDescription
        self.tags = tags
        self.useCases = useCases
        self.riskLevel = riskLevel
        self.riskNote = riskNote
        self.usageNote = usageNote
        self.updatedAt = updatedAt
    }
}

public struct SkillNoteMatch: Equatable, Sendable {
    public let note: SkillNote
    public let isStale: Bool

    public init(note: SkillNote, isStale: Bool) {
        self.note = note
        self.isStale = isStale
    }
}
