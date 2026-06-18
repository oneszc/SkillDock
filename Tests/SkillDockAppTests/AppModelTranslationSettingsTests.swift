import Foundation
import SkillDockCore
import XCTest
@testable import SkillDockApp

@MainActor
final class AppModelTranslationSettingsTests: XCTestCase {
    func testAPIKeyUsesCredentialStoreAndNeverSettingsJSON() async throws {
        let directory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(".build/test-tmp/\(UUID().uuidString)", isDirectory: true)
        let settingsStore = SettingsStore(directory: directory)
        let credentials = AppMemoryCredentialStore()
        let model = AppModel(
            settingsStore: settingsStore,
            translationService: AppStubTranslationService(),
            translationCredentialStore: credentials
        )
        model.settings = SkillSettings.defaults()

        await model.saveTranslationAPIKey("secret-key")
        model.settings.translation.model = DeepSeekModel.pro.rawValue
        await model.saveTranslationConfiguration()

        let savedKey = await credentials.value(providerID: "deepseek")
        XCTAssertEqual(savedKey, "secret-key")
        let settingsData = try Data(contentsOf: directory.appendingPathComponent("settings.json"))
        let settingsJSON = String(decoding: settingsData, as: UTF8.self)
        XCTAssertFalse(settingsJSON.contains("secret-key"))
        let savedSettings = try await settingsStore.load()
        XCTAssertEqual(savedSettings.translation.model, DeepSeekModel.pro.rawValue)
    }

    func testBlankAPIKeyDeletesCredential() async {
        let credentials = AppMemoryCredentialStore(values: ["deepseek": "secret"])
        let model = AppModel(
            translationService: AppStubTranslationService(),
            translationCredentialStore: credentials
        )

        await model.saveTranslationAPIKey("  ")

        let savedKey = await credentials.value(providerID: "deepseek")
        XCTAssertNil(savedKey)
    }

    func testConnectionMapsSuccessAndFailureState() async {
        let successModel = AppModel(
            translationService: AppStubTranslationService(),
            translationCredentialStore: AppMemoryCredentialStore()
        )
        await successModel.testTranslationConnection()
        XCTAssertEqual(successModel.translationConnectionState, .succeeded)

        let failureModel = AppModel(
            translationService: AppStubTranslationService(error: TranslationProviderError.invalidAPIKey),
            translationCredentialStore: AppMemoryCredentialStore()
        )
        await failureModel.testTranslationConnection()
        XCTAssertEqual(
            failureModel.translationConnectionState,
            .failed(TranslationProviderError.invalidAPIKey.localizedDescription)
        )
    }
}

private actor AppMemoryCredentialStore: TranslationCredentialStoring {
    var values: [String: String]

    init(values: [String: String] = [:]) { self.values = values }
    func apiKey(providerID: String) -> String? { values[providerID] }
    func saveAPIKey(_ apiKey: String, providerID: String) { values[providerID] = apiKey }
    func deleteAPIKey(providerID: String) { values.removeValue(forKey: providerID) }
    func value(providerID: String) -> String? { values[providerID] }
}

private actor AppStubTranslationService: SkillTranslationServicing {
    let error: Error?

    init(error: Error? = nil) { self.error = error }
    func hasAPIKey(settings: TranslationSettings) -> Bool { true }
    func testConnection(settings: TranslationSettings) throws {
        if let error { throw error }
    }
    func generate(
        skill: Skill,
        markdown: String,
        settings: TranslationSettings
    ) throws -> SkillTranslation {
        fatalError("Not used")
    }
}
