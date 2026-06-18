import Foundation
import SkillDockCore
import XCTest
@testable import SkillDockApp

final class TranslationPresentationTests: XCTestCase {
    func testTranslatedMarkdownUsesTranslationWithoutChangingSkillName() {
        let record = makeRecord(stale: false)

        let presentation = TranslationPresentation(
            record: record,
            originalMarkdown: "# Original",
            language: .translated,
            showsMarkdown: true,
            isGenerating: false,
            errorMessage: nil,
            hasAPIKey: true
        )

        XCTAssertEqual(presentation.title, "sample-skill")
        XCTAssertEqual(presentation.description, "中文介绍")
        XCTAssertEqual(presentation.markdown, "# 中文正文")
        XCTAssertEqual(presentation.state, .available(isStale: false))
    }

    func testFilesAndInstallAlwaysUseOriginalDescription() {
        let presentation = TranslationPresentation(
            record: makeRecord(stale: false),
            originalMarkdown: "# Original",
            language: .translated,
            showsMarkdown: false,
            isGenerating: false,
            errorMessage: nil,
            hasAPIKey: true
        )

        XCTAssertEqual(presentation.description, "English description")
        XCTAssertEqual(presentation.markdown, "# Original")
    }

    func testMissingAndStaleStatesAreActionable() {
        let missing = TranslationPresentation(
            record: makeRecord(translation: nil),
            originalMarkdown: "# Original",
            language: .translated,
            showsMarkdown: true,
            isGenerating: false,
            errorMessage: nil,
            hasAPIKey: false
        )
        let stale = TranslationPresentation(
            record: makeRecord(stale: true),
            originalMarkdown: "# Original",
            language: .translated,
            showsMarkdown: true,
            isGenerating: false,
            errorMessage: nil,
            hasAPIKey: true
        )

        XCTAssertEqual(missing.state, .missingConfiguration)
        XCTAssertEqual(stale.state, .available(isStale: true))
    }

    func testGeneratingAndFailureTakePriorityOverEmptyState() {
        let record = makeRecord(translation: nil)
        let generating = TranslationPresentation(
            record: record,
            originalMarkdown: "body",
            language: .translated,
            showsMarkdown: true,
            isGenerating: true,
            errorMessage: nil,
            hasAPIKey: true
        )
        let failure = TranslationPresentation(
            record: record,
            originalMarkdown: "body",
            language: .translated,
            showsMarkdown: true,
            isGenerating: false,
            errorMessage: "Network unavailable",
            hasAPIKey: true
        )

        XCTAssertEqual(generating.state, .generating)
        XCTAssertEqual(failure.state, .failed("Network unavailable"))
    }

    private func makeRecord(
        stale: Bool = false,
        translation: SkillTranslation? = SkillTranslation(
            skillName: "sample-skill",
            source: .library,
            contentHash: "hash",
            translatedDescription: "中文介绍",
            translatedMarkdown: "# 中文正文",
            providerID: "deepseek",
            model: "model",
            generatedAt: Date(timeIntervalSince1970: 1)
        )
    ) -> SkillRecord {
        SkillRecord(
            skill: Skill(
                id: "sample",
                name: "sample-skill",
                description: "English description",
                path: URL(fileURLWithPath: "/tmp/sample"),
                source: .library,
                hasScripts: false,
                isSystem: false,
                isReadOnly: false,
                contentHash: stale ? "new-hash" : "hash"
            ),
            note: nil,
            isNoteStale: false,
            translation: translation,
            isTranslationStale: stale
        )
    }
}
