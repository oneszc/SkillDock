import XCTest
@testable import SkillDockCore

final class NotesStoreTests: XCTestCase {
    func testSavesNotesOutsideSkillDirectory() async throws {
        let skillDirectory = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: skillDirectory)
        let appSupport = try Fixtures.temporaryDirectory()
        let store = NotesStore(directory: appSupport)

        try await store.save([makeNote(hash: "hash-1")])

        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: appSupport.appendingPathComponent("notes.json").path
            )
        )
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: skillDirectory.appendingPathComponent(".skilldock.json").path
            )
        )
    }

    func testLoadingNotesDoesNotModifyOriginalSkill() async throws {
        let skillDirectory = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: skillDirectory)
        let before = try Fixtures.snapshot(directory: skillDirectory)
        let store = NotesStore(directory: try Fixtures.temporaryDirectory())
        try await store.save([makeNote(hash: "hash-1")])

        _ = try await store.load()

        XCTAssertEqual(try Fixtures.snapshot(directory: skillDirectory), before)
    }

    func testFindsCurrentNoteByNameSourceAndHash() async throws {
        let store = NotesStore(directory: try Fixtures.temporaryDirectory())
        try await store.save([makeNote(hash: "hash-1")])

        let match = try await store.match(
            name: "sample-skill",
            source: .library,
            contentHash: "hash-1"
        )

        XCTAssertEqual(match?.note.chineseName, "示例技能")
        XCTAssertEqual(match?.isStale, false)
    }

    func testMarksPreviousNoteStaleWhenHashChanges() async throws {
        let store = NotesStore(directory: try Fixtures.temporaryDirectory())
        try await store.save([makeNote(hash: "hash-1")])

        let match = try await store.match(
            name: "sample-skill",
            source: .library,
            contentHash: "hash-2"
        )

        XCTAssertEqual(match?.note.chineseName, "示例技能")
        XCTAssertEqual(match?.isStale, true)
    }

    func testSettingsUseExpectedDefaultPaths() {
        let home = URL(fileURLWithPath: "/Users/designer", isDirectory: true)

        let settings = SkillSettings.defaults(homeDirectory: home)

        XCTAssertEqual(settings.libraryPath.path, "/Users/designer/AI-Skills")
        XCTAssertEqual(settings.codexPath.path, "/Users/designer/.codex/skills")
        XCTAssertEqual(settings.claudePath.path, "/Users/designer/.claude/skills")
    }

    private func makeNote(hash: String) -> SkillNote {
        SkillNote(
            key: SkillNoteKey(
                name: "sample-skill",
                source: .library,
                contentHash: hash
            ),
            chineseName: "示例技能",
            chineseDescription: "帮助理解一个示例技能。",
            tags: ["示例"],
            useCases: ["测试"],
            riskLevel: .low,
            riskNote: "",
            usageNote: "",
            updatedAt: Date(timeIntervalSince1970: 1)
        )
    }
}
