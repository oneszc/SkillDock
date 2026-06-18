import XCTest
@testable import SkillDockCore

final class SkillSearchTests: XCTestCase {
    func testSearchMatchesEnglishNameAndDescription() {
        let records = [makeRecord()]
        let search = SkillSearch()

        XCTAssertEqual(search.filter(records, query: "sample").count, 1)
        XCTAssertEqual(search.filter(records, query: "description").count, 1)
    }

    func testSearchMatchesCurrentTranslationButNotLegacyNotes() {
        let records = [makeRecord()]
        let search = SkillSearch()

        XCTAssertTrue(search.filter(records, query: "示例技能").isEmpty)
        XCTAssertTrue(search.filter(records, query: "旧备注").isEmpty)
        XCTAssertEqual(search.filter(records, query: "中文介绍").count, 1)
    }

    func testSystemFilterReturnsOnlySystemSkills() {
        let records = [
            makeRecord(isSystem: false),
            makeRecord(isSystem: true, id: "system")
        ]

        let result = SkillSearch().filter(records, query: "", systemOnly: true)

        XCTAssertEqual(result.map(\.id), ["system"])
    }

    private func makeRecord(isSystem: Bool = false, id: String = "sample") -> SkillRecord {
        let skill = Skill(
            id: id,
            name: "sample-skill",
            description: "Sample description",
            path: URL(fileURLWithPath: "/tmp/sample-skill"),
            source: .library,
            hasScripts: false,
            isSystem: isSystem,
            isReadOnly: isSystem,
            contentHash: "hash"
        )
        let note = SkillNote(
            key: SkillNoteKey(name: skill.name, source: skill.source, contentHash: skill.contentHash),
            chineseName: "示例技能",
            chineseDescription: "旧备注内容。",
            tags: ["设计"],
            useCases: [],
            riskLevel: .low,
            riskNote: "",
            usageNote: "",
            updatedAt: Date(timeIntervalSince1970: 1)
        )
        let translation = SkillTranslation(
            skillName: skill.name,
            source: skill.source,
            contentHash: skill.contentHash,
            translatedDescription: "中文介绍内容。",
            translatedMarkdown: "# 中文正文",
            providerID: TranslationProviderID.deepSeek,
            model: DeepSeekModel.flash.rawValue,
            generatedAt: Date(timeIntervalSince1970: 1)
        )
        return SkillRecord(
            skill: skill,
            note: note,
            isNoteStale: false,
            translation: translation,
            isTranslationStale: false
        )
    }
}
