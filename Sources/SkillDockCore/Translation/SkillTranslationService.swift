import Foundation

public protocol SkillTranslationServicing: Sendable {
    func hasAPIKey(settings: TranslationSettings) async -> Bool
    func testConnection(settings: TranslationSettings) async throws
    func generate(
        skill: Skill,
        markdown: String,
        settings: TranslationSettings
    ) async throws -> SkillTranslation
}

public enum SkillTranslationServiceError: Error, Equatable, LocalizedError, Sendable {
    case missingAPIKey
    case providerUnavailable
    case invalidOutput

    public var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            "Add your DeepSeek API key in Settings before generating a translation."
        case .providerUnavailable:
            "The configured translation provider is unavailable."
        case .invalidOutput:
            "The translation was empty and was not saved. Try again."
        }
    }
}

public actor SkillTranslationService: SkillTranslationServicing {
    private let providers: [String: any TranslationProviding]
    private let credentialStore: any TranslationCredentialStoring
    private let translationStore: TranslationStore
    private let now: @Sendable () -> Date

    public init(
        providers: [any TranslationProviding] = [DeepSeekTranslationProvider()],
        credentialStore: any TranslationCredentialStoring = KeychainTranslationCredentialStore(),
        translationStore: TranslationStore = .init(),
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.providers = Dictionary(uniqueKeysWithValues: providers.map { ($0.id, $0) })
        self.credentialStore = credentialStore
        self.translationStore = translationStore
        self.now = now
    }

    public func hasAPIKey(settings: TranslationSettings) async -> Bool {
        guard let key = try? await credentialStore.apiKey(providerID: settings.providerID) else {
            return false
        }
        return !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public func testConnection(settings: TranslationSettings) async throws {
        let (provider, apiKey) = try await configuration(settings: settings)
        try await provider.testConnection(apiKey: apiKey, model: settings.model)
    }

    public func generate(
        skill: Skill,
        markdown: String,
        settings: TranslationSettings
    ) async throws -> SkillTranslation {
        let (provider, apiKey) = try await configuration(settings: settings)
        let output = try await provider.translate(
            SkillTranslationRequest(
                skillName: skill.name,
                description: skill.description ?? "",
                markdown: markdown
            ),
            apiKey: apiKey,
            model: settings.model
        )
        let description = output.translatedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let translatedMarkdown = output.translatedMarkdown.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !description.isEmpty, !translatedMarkdown.isEmpty else {
            throw SkillTranslationServiceError.invalidOutput
        }

        let translation = SkillTranslation(
            skillName: skill.name,
            source: skill.source,
            contentHash: skill.contentHash,
            translatedDescription: description,
            translatedMarkdown: translatedMarkdown,
            providerID: settings.providerID,
            model: settings.model,
            generatedAt: now()
        )
        try await translationStore.upsert(translation)
        return translation
    }

    private func configuration(
        settings: TranslationSettings
    ) async throws -> (any TranslationProviding, String) {
        guard let provider = providers[settings.providerID] else {
            throw SkillTranslationServiceError.providerUnavailable
        }
        guard let key = try await credentialStore.apiKey(providerID: settings.providerID),
              !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            throw SkillTranslationServiceError.missingAPIKey
        }
        return (provider, key)
    }
}
