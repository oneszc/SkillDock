import XCTest
@testable import SkillDockCore

final class SkillSearchTests: XCTestCase {
    func testSearchMatchesEnglishNameAndDescription() {
        let records = [makeRecord()]
        let search = SkillSearch()

        XCTAssertEqual(search.filter(records, query: "sample").count, 1)
        XCTAssertEqual(search.filter(records, query: "description").count, 1)
    }

    func testSearchMatchesChineseDescriptionAndTagsButNotLegacyChineseName() {
        let records = [makeRecord()]
        let search = SkillSearch()

        XCTAssertTrue(search.filter(records, query: "示例技能").isEmpty)
        XCTAssertEqual(search.filter(records, query: "帮助理解").count, 1)
        XCTAssertEqual(search.filter(records, query: "设计").count, 1)
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
            chineseDescription: "帮助理解这个技能。",
            tags: ["设计"],
            useCases: [],
            riskLevel: .low,
            riskNote: "",
            usageNote: "",
            updatedAt: Date(timeIntervalSince1970: 1)
        )
        return SkillRecord(skill: skill, note: note, isNoteStale: false)
    }
}
