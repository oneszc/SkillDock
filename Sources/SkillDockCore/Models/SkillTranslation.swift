import Foundation

public struct SkillTranslation: Codable, Equatable, Sendable {
    public let skillName: String
    public let source: SkillSource
    public let contentHash: String
    public let translatedDescription: String
    public let translatedMarkdown: String
    public let providerID: String
    public let model: String
    public let generatedAt: Date

    public init(
        skillName: String,
        source: SkillSource,
        contentHash: String,
        translatedDescription: String,
        translatedMarkdown: String,
        providerID: String,
        model: String,
        generatedAt: Date
    ) {
        self.skillName = skillName
        self.source = source
        self.contentHash = contentHash
        self.translatedDescription = translatedDescription
        self.translatedMarkdown = translatedMarkdown
        self.providerID = providerID
        self.model = model
        self.generatedAt = generatedAt
    }
}

public struct SkillTranslationMatch: Equatable, Sendable {
    public let translation: SkillTranslation
    public let isStale: Bool

    public init(translation: SkillTranslation, isStale: Bool) {
        self.translation = translation
        self.isStale = isStale
    }
}
