import Foundation
import XCTest
@testable import SkillDockCore

final class SkillTranslationServiceTests: XCTestCase {
    func testGenerateRequiresConfiguredAPIKey() async throws {
        let provider = StubTranslationProvider()
        let service = SkillTranslationService(
            providers: [provider],
            credentialStore: MemoryCredentialStore(),
            translationStore: TranslationStore(directory: try Fixtures.temporaryDirectory())
        )

        do {
            _ = try await service.generate(
                skill: makeSkill(),
                markdown: "# Body",
                settings: TranslationSettings()
            )
            XCTFail("Expected missing API key")
        } catch let error as SkillTranslationServiceError {
            XCTAssertEqual(error, .missingAPIKey)
        }
        let callCount = await provider.translateCallCount
        XCTAssertEqual(callCount, 0)
    }

    func testGeneratePersistsCompleteTranslation() async throws {
        let directory = try Fixtures.temporaryDirectory()
        let store = TranslationStore(directory: directory)
        let credentials = MemoryCredentialStore(values: ["deepseek": "secret"])
        let provider = StubTranslationProvider(
            output: SkillTranslationOutput(
                translatedDescription: "中文介绍",
                translatedMarkdown: "# 中文正文"
            )
        )
        let service = SkillTranslationService(
            providers: [provider],
            credentialStore: credentials,
            translationStore: store,
            now: { Date(timeIntervalSince1970: 10) }
        )
        let skill = makeSkill()

        let translation = try await service.generate(
            skill: skill,
            markdown: "# Body",
            settings: TranslationSettings()
        )
        let saved = try await store.match(
            name: skill.name,
            source: skill.source,
            contentHash: skill.contentHash
        )

        XCTAssertEqual(saved?.translation, translation)
        XCTAssertEqual(translation.translatedDescription, "中文介绍")
        XCTAssertEqual(translation.generatedAt, Date(timeIntervalSince1970: 10))
    }

    func testProviderFailureKeepsExistingTranslation() async throws {
        let store = TranslationStore(directory: try Fixtures.temporaryDirectory())
        let existing = makeTranslation(description: "旧译文")
        try await store.upsert(existing)
        let provider = StubTranslationProvider(error: TranslationProviderError.networkUnavailable)
        let service = SkillTranslationService(
            providers: [provider],
            credentialStore: MemoryCredentialStore(values: ["deepseek": "secret"]),
            translationStore: store
        )

        do {
            _ = try await service.generate(
                skill: makeSkill(),
                markdown: "# Body",
                settings: TranslationSettings()
            )
            XCTFail("Expected provider failure")
        } catch {
            XCTAssertEqual(error as? TranslationProviderError, .networkUnavailable)
        }

        let saved = try await store.load()
        XCTAssertEqual(saved, [existing])
    }

    func testConnectionUsesConfiguredProviderAndCredential() async throws {
        let provider = StubTranslationProvider()
        let service = SkillTranslationService(
            providers: [provider],
            credentialStore: MemoryCredentialStore(values: ["deepseek": "secret"]),
            translationStore: TranslationStore(directory: try Fixtures.temporaryDirectory())
        )

        try await service.testConnection(settings: TranslationSettings(model: "chosen-model"))

        let models = await provider.connectionModels
        XCTAssertEqual(models, ["chosen-model"])
    }

    private func makeSkill() -> Skill {
        Skill(
            id: "library:sample",
            name: "sample-skill",
            description: "English description",
            path: URL(fileURLWithPath: "/tmp/sample-skill"),
            source: .library,
            hasScripts: false,
            isSystem: false,
            isReadOnly: false,
            contentHash: "hash"
        )
    }

    private func makeTranslation(description: String) -> SkillTranslation {
        SkillTranslation(
            skillName: "sample-skill",
            source: .library,
            contentHash: "hash",
            translatedDescription: description,
            translatedMarkdown: "# 旧正文",
            providerID: "deepseek",
            model: "model",
            generatedAt: Date(timeIntervalSince1970: 1)
        )
    }
}

private actor MemoryCredentialStore: TranslationCredentialStoring {
    var values: [String: String]

    init(values: [String: String] = [:]) {
        self.values = values
    }

    func apiKey(providerID: String) -> String? { values[providerID] }
    func saveAPIKey(_ apiKey: String, providerID: String) { values[providerID] = apiKey }
    func deleteAPIKey(providerID: String) { values.removeValue(forKey: providerID) }
}

private actor StubTranslationProvider: TranslationProviding {
    nonisolated let id = "deepseek"
    let output: SkillTranslationOutput
    let error: Error?
    private(set) var translateCallCount = 0
    private(set) var connectionModels: [String] = []

    init(
        output: SkillTranslationOutput = .init(
            translatedDescription: "中文介绍",
            translatedMarkdown: "# 中文正文"
        ),
        error: Error? = nil
    ) {
        self.output = output
        self.error = error
    }

    func testConnection(apiKey: String, model: String) throws {
        connectionModels.append(model)
        if let error { throw error }
    }

    func translate(
        _ request: SkillTranslationRequest,
        apiKey: String,
        model: String
    ) throws -> SkillTranslationOutput {
        translateCallCount += 1
        if let error { throw error }
        return output
    }
}
