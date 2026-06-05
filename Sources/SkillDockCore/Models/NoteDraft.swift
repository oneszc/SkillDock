import Foundation

public struct NoteSuggestions: Equatable, Sendable {
    public let tags: [String]
    public let useCases: [String]

    public init(tags: [String], useCases: [String]) {
        self.tags = tags
        self.useCases = useCases
    }
}

public struct NoteDraft: Equatable, Sendable {
    public var chineseName: String
    public var chineseDescription: String
    public var tags: [String]
    public var useCases: [String]
    public var riskLevel: RiskLevel
    public var riskNote: String
    public var usageNote: String

    public init(note: SkillNote?) {
        chineseName = note?.chineseName ?? ""
        chineseDescription = note?.chineseDescription ?? ""
        tags = note?.tags ?? []
        useCases = note?.useCases ?? []
        riskLevel = note?.riskLevel ?? .unknown
        riskNote = note?.riskNote ?? ""
        usageNote = note?.usageNote ?? ""
    }
}
