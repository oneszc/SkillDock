import XCTest
@testable import SkillDockCore

final class SkillLibraryBuilderTests: XCTestCase {
    func testMergesSameNamedSkillAcrossSourcesIntoInstallationStatus() {
        let skills = [
            makeSkill(source: .library, hash: "same"),
            makeSkill(source: .codex, hash: "same"),
            makeSkill(source: .claude, hash: "same")
        ]

        let records = SkillLibraryBuilder().build(skills: skills, notes: [])

        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.skill.source, .library)
        XCTAssertEqual(records.first?.skill.installation, SkillInstallation(codex: true, claude: true))
    }

    func testKeepsDifferentContentHashesAsDistinctRecords() {
        let skills = [
            makeSkill(source: .library, hash: "first"),
            makeSkill(source: .codex, hash: "second")
        ]

        let records = SkillLibraryBuilder().build(skills: skills, notes: [])

        XCTAssertEqual(records.count, 2)
    }

    func testMarksPreviousMatchingNoteAsStale() {
        let skill = makeSkill(source: .library, hash: "new")
        let note = SkillNote(
            key: SkillNoteKey(name: skill.name, source: .library, contentHash: "old"),
            chineseName: "示例技能",
            chineseDescription: "",
            tags: [],
            useCases: [],
            riskLevel: .unknown,
            riskNote: "",
            usageNote: "",
            updatedAt: Date(timeIntervalSince1970: 1)
        )

        let record = SkillLibraryBuilder().build(skills: [skill], notes: [note]).first

        XCTAssertEqual(record?.note, note)
        XCTAssertEqual(record?.isNoteStale, true)
    }

    func testAttachesCurrentAndStaleTranslationMatches() {
        let skill = makeSkill(source: .library, hash: "new")
        let translation = SkillTranslation(
            skillName: skill.name,
            source: skill.source,
            contentHash: "old",
            translatedDescription: "中文介绍",
            translatedMarkdown: "# 中文正文",
            providerID: TranslationProviderID.deepSeek,
            model: DeepSeekModel.flash.rawValue,
            generatedAt: Date(timeIntervalSince1970: 1)
        )

        let staleRecord = SkillLibraryBuilder().build(
            skills: [skill],
            notes: [],
            translations: [translation]
        ).first
        let currentSkill = makeSkill(source: .library, hash: "old")
        let currentRecord = SkillLibraryBuilder().build(
            skills: [currentSkill],
            notes: [],
            translations: [translation]
        ).first

        XCTAssertEqual(staleRecord?.translation, translation)
        XCTAssertEqual(staleRecord?.isTranslationStale, true)
        XCTAssertEqual(currentRecord?.isTranslationStale, false)
    }

    private func makeSkill(source: SkillSource, hash: String) -> Skill {
        Skill(
            id: "\(source.rawValue):sample:\(hash)",
            name: "sample-skill",
            description: "Sample description",
            path: URL(fileURLWithPath: "/tmp/\(source.rawValue)/sample-skill"),
            source: source,
            hasScripts: false,
            isSystem: false,
            isReadOnly: false,
            contentHash: hash,
            installation: SkillInstallation(
                codex: source == .codex,
                claude: source == .claude
            )
        )
    }
}
