import Foundation

public struct SkillTranslationRequest: Equatable, Sendable {
    public let skillName: String
    public let description: String
    public let markdown: String

    public init(skillName: String, description: String, markdown: String) {
        self.skillName = skillName
        self.description = description
        self.markdown = markdown
    }
}

public struct SkillTranslationOutput: Codable, Equatable, Sendable {
    public let translatedDescription: String
    public let translatedMarkdown: String

    public init(translatedDescription: String, translatedMarkdown: String) {
        self.translatedDescription = translatedDescription
        self.translatedMarkdown = translatedMarkdown
    }
}

public protocol TranslationProviding: Sendable {
    var id: String { get }

    func testConnection(apiKey: String, model: String) async throws

    func translate(
        _ request: SkillTranslationRequest,
        apiKey: String,
        model: String
    ) async throws -> SkillTranslationOutput
}

public enum TranslationProviderError: Error, Equatable, LocalizedError, Sendable {
    case invalidAPIKey
    case modelUnavailable
    case networkUnavailable
    case contentTooLong
    case invalidResponse

    public var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            "The API key is invalid. Check it in Settings."
        case .modelUnavailable:
            "The selected model is unavailable. Choose another model and try again."
        case .networkUnavailable:
            "DeepSeek could not be reached. Check your connection and try again."
        case .contentTooLong:
            "This Skill is too long to translate in one request."
        case .invalidResponse:
            "DeepSeek returned an unreadable translation. Try again."
        }
    }
}
