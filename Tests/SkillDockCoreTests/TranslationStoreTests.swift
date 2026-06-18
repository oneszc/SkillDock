import XCTest
@testable import SkillDockCore

final class TranslationStoreTests: XCTestCase {
    func testStoresTranslationsOutsideSkillDirectory() async throws {
        let skillDirectory = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: skillDirectory)
        let appSupport = try Fixtures.temporaryDirectory()
        let store = TranslationStore(directory: appSupport)

        try await store.upsert(makeTranslation(hash: "hash-1"))

        XCTAssertTrue(FileManager.default.fileExists(
            atPath: appSupport.appendingPathComponent("translations.json").path
        ))
        XCTAssertFalse(FileManager.default.fileExists(
            atPath: skillDirectory.appendingPathComponent("translations.json").path
        ))
    }

    func testMatchesExactTranslationAndMarksChangedContentStale() async throws {
        let store = TranslationStore(directory: try Fixtures.temporaryDirectory())
        let translation = makeTranslation(hash: "hash-1")
        try await store.upsert(translation)

        let current = try await store.match(
            name: "sample-skill",
            source: .library,
            contentHash: "hash-1"
        )
        let stale = try await store.match(
            name: "sample-skill",
            source: .library,
            contentHash: "hash-2"
        )

        XCTAssertEqual(current, SkillTranslationMatch(translation: translation, isStale: false))
        XCTAssertEqual(stale, SkillTranslationMatch(translation: translation, isStale: true))
    }

    private func makeTranslation(hash: String) -> SkillTranslation {
        SkillTranslation(
            skillName: "sample-skill",
            source: .library,
            contentHash: hash,
            translatedDescription: "中文介绍",
            translatedMarkdown: "# 中文正文",
            providerID: TranslationProviderID.deepSeek,
            model: DeepSeekModel.flash.rawValue,
            generatedAt: Date(timeIntervalSince1970: 1)
        )
    }
}
