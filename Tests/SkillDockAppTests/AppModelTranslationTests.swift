import Foundation
import SkillDockCore
import XCTest
@testable import SkillDockApp

@MainActor
final class AppModelTranslationTests: XCTestCase {
    func testGenerationCapturesOriginalSkillWhenSelectionChanges() async throws {
        let service = RecordingTranslationService()
        let model = AppModel(translationService: service)
        let first = makeRecord(id: "first", name: "first-skill")
        let second = makeRecord(id: "second", name: "second-skill")
        model.records = [first, second]
        model.selectionID = first.id
        model.markdown = "# First body"

        let generation = Task { await model.generateSelectedTranslation() }
        try await Task.sleep(for: .milliseconds(10))
        model.selectionID = second.id
        await generation.value

        let receivedNames = await service.receivedSkillNames
        let receivedMarkdown = await service.receivedMarkdown
        XCTAssertEqual(receivedNames, ["first-skill"])
        XCTAssertEqual(receivedMarkdown, ["# First body"])
    }

    private func makeRecord(id: String, name: String) -> SkillRecord {
        SkillRecord(
            skill: Skill(
                id: id,
                name: name,
                description: "Description",
                path: URL(fileURLWithPath: "/tmp/\(name)"),
                source: .library,
                hasScripts: false,
                isSystem: false,
                isReadOnly: false,
                contentHash: "hash-\(id)"
            ),
            note: nil,
            isNoteStale: false
        )
    }
}

private actor RecordingTranslationService: SkillTranslationServicing {
    private(set) var receivedSkillNames: [String] = []
    private(set) var receivedMarkdown: [String] = []

    func hasAPIKey(settings: TranslationSettings) -> Bool { true }
    func testConnection(settings: TranslationSettings) {}

    func generate(
        skill: Skill,
        markdown: String,
        settings: TranslationSettings
    ) async throws -> SkillTranslation {
        receivedSkillNames.append(skill.name)
        receivedMarkdown.append(markdown)
        try await Task.sleep(for: .milliseconds(30))
        return SkillTranslation(
            skillName: skill.name,
            source: skill.source,
            contentHash: skill.contentHash,
            translatedDescription: "中文介绍",
            translatedMarkdown: "# 中文正文",
            providerID: settings.providerID,
            model: settings.model,
            generatedAt: Date()
        )
    }
}
