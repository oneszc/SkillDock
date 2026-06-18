import Foundation
import XCTest
@testable import SkillDockCore

final class TranslationSettingsTests: XCTestCase {
    func testDefaultsUseDeepSeekFlashWithoutPersistedCredential() throws {
        let settings = SkillSettings.defaults(
            homeDirectory: URL(fileURLWithPath: "/Users/designer", isDirectory: true)
        )

        XCTAssertEqual(settings.translation.providerID, TranslationProviderID.deepSeek)
        XCTAssertEqual(settings.translation.model, DeepSeekModel.flash.rawValue)

        let json = String(decoding: try JSONEncoder().encode(settings), as: UTF8.self)
        XCTAssertFalse(json.localizedCaseInsensitiveContains("apiKey"))
    }

    func testTranslationSettingsRoundTrip() throws {
        var settings = SkillSettings.defaults()
        settings.translation = TranslationSettings(
            providerID: TranslationProviderID.deepSeek,
            model: DeepSeekModel.pro.rawValue
        )

        let data = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(SkillSettings.self, from: data)

        XCTAssertEqual(decoded.translation, settings.translation)
    }

    func testOlderSettingsDefaultTranslationConfiguration() throws {
        let data = """
        {
          "libraryPath": "file:///Users/designer/AI-Skills/",
          "codexPath": "file:///Users/designer/.codex/skills/",
          "claudePath": "file:///Users/designer/.claude/skills/",
          "showSystemSkills": true,
          "defaultInstallTargets": ["codex", "claude"],
          "defaultConflictStrategy": "skip"
        }
        """.data(using: .utf8)!

        let settings = try JSONDecoder().decode(SkillSettings.self, from: data)

        XCTAssertEqual(settings.translation, TranslationSettings())
    }
}
