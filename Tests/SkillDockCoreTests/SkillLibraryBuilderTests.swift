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

    func testMergedRecordPreservesAllPhysicalCopies() {
        let library = makeSkill(source: .library, hash: "same")
        let codexSystem = makeSkill(
            source: .codex,
            hash: "same",
            path: URL(fileURLWithPath: "/tmp/codex/.system/sample-skill"),
            isSystem: true
        )
        let claude = makeSkill(source: .claude, hash: "same")

        let record = SkillLibraryBuilder()
            .build(skills: [library, codexSystem, claude], notes: [])
            .first

        XCTAssertEqual(record?.skill.source, .library)
        XCTAssertEqual(record?.skill.installation, SkillInstallation(codex: true, claude: true))
        XCTAssertEqual(record?.physicalCopies.count, 3)
        XCTAssertEqual(record?.hasSystemCopy, true)
        XCTAssertEqual(record?.systemCopy?.path, codexSystem.path)
    }

    func testSystemCopyDoesNotMakePreferredLibrarySkillReadOnly() {
        let library = makeSkill(source: .library, hash: "same")
        let codexSystem = makeSkill(
            source: .codex,
            hash: "same",
            path: URL(fileURLWithPath: "/tmp/codex/.system/sample-skill"),
            isSystem: true
        )

        let record = SkillLibraryBuilder()
            .build(skills: [library, codexSystem], notes: [])
            .first

        XCTAssertEqual(record?.skill.path, library.path)
        XCTAssertEqual(record?.skill.isSystem, false)
        XCTAssertEqual(record?.hasSystemCopy, true)
    }

    func testKeepsDifferentContentHashesAsDistinctRecords() {
        let skills = [
            makeSkill(source: .library, hash: "first"),
            makeSkill(source: .available(.personal), hash: "second")
        ]

        let records = SkillLibraryBuilder().build(skills: skills, notes: [])

        XCTAssertEqual(records.count, 2)
    }

    func testAvailableCopyIsNotInstalledCopy() {
        let personal = makeSkill(source: .available(.personal), hash: "same")
        let record = SkillLibraryBuilder().build(skills: [personal], notes: []).first

        XCTAssertEqual(record?.hasAvailableCopy, true)
        XCTAssertEqual(record?.hasInstalledCopy, false)
        XCTAssertEqual(record?.availableSources, [.personal])
    }

    func testMergesPersonalSystemAndAgentCopiesWithoutLosingSources() {
        let skills = [
            makeSkill(source: .available(.personal), hash: "same"),
            makeSkill(source: .available(.system), hash: "same", isSystem: true),
            makeSkill(source: .codex, hash: "same")
        ]

        let record = SkillLibraryBuilder().build(skills: skills, notes: []).first

        XCTAssertEqual(record?.availableSources, [.personal, .system])
        XCTAssertEqual(record?.skill.installation.agentIDs, [AgentTargetID.codex])
        XCTAssertEqual(record?.physicalCopies.count, 3)
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

    func testAvailableSystemSkillUsesMatchingLegacyCodexTranslation() {
        let skill = makeSkill(
            source: .available(.system),
            hash: "same",
            isSystem: true
        )
        let translation = SkillTranslation(
            skillName: skill.name,
            source: .codex,
            contentHash: skill.contentHash,
            translatedDescription: "Legacy system translation",
            translatedMarkdown: "# Legacy system translation",
            providerID: TranslationProviderID.deepSeek,
            model: DeepSeekModel.flash.rawValue,
            generatedAt: Date(timeIntervalSince1970: 1)
        )

        let record = SkillLibraryBuilder().build(
            skills: [skill],
            notes: [],
            translations: [translation]
        ).first

        XCTAssertEqual(record?.translation, translation)
        XCTAssertEqual(record?.isTranslationStale, false)
    }

    private func makeSkill(
        source: SkillSource,
        hash: String,
        path: URL? = nil,
        isSystem: Bool = false
    ) -> Skill {
        Skill(
            id: "\(source.rawValue):sample:\(hash)",
            name: "sample-skill",
            description: "Sample description",
            path: path ?? URL(fileURLWithPath: "/tmp/\(source.rawValue)/sample-skill"),
            source: source,
            hasScripts: false,
            isSystem: isSystem,
            isReadOnly: isSystem,
            contentHash: hash,
            installation: SkillInstallation(
                codex: source == .codex,
                claude: source == .claude
            )
        )
    }
}
