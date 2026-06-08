import XCTest
@testable import SkillDockCore

final class SkillWorkspaceServiceTests: XCTestCase {
    func testFileTreeListsRelativePathsWithoutWritingFiles() async throws {
        let skillDirectory = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: skillDirectory)
        try Fixtures.write(
            "print('hello')",
            to: skillDirectory.appendingPathComponent("scripts/run.py")
        )
        let before = try Fixtures.snapshot(directory: skillDirectory)

        let paths = try await SkillWorkspaceService().fileTree(for: skillDirectory)

        XCTAssertEqual(paths, ["scripts", "scripts/run.py", "SKILL.md"])
        XCTAssertEqual(try Fixtures.snapshot(directory: skillDirectory), before)
    }

    func testSavingNoteRefreshesRecordWithoutChangingSkillHash() async throws {
        let library = try Fixtures.temporaryDirectory()
        let skillDirectory = library.appendingPathComponent("sample-skill")
        try Fixtures.makeSkill(at: skillDirectory)
        let notesDirectory = try Fixtures.temporaryDirectory()
        let notesStore = NotesStore(directory: notesDirectory)
        let libraryService = SkillLibraryService(notesStore: notesStore)
        let workspace = SkillWorkspaceService(notesStore: notesStore)
        let settings = SkillSettings(
            libraryPath: library,
            codexPath: try Fixtures.temporaryDirectory(),
            claudePath: try Fixtures.temporaryDirectory()
        )
        let original = try await libraryService.refresh(settings: settings).first!
        let note = SkillNote(
            key: SkillNoteKey(
                name: original.skill.name,
                source: original.skill.source,
                contentHash: original.skill.contentHash
            ),
            chineseName: "示例技能",
            chineseDescription: "中文说明",
            tags: ["示例"],
            useCases: [],
            riskLevel: .low,
            riskNote: "",
            usageNote: "",
            updatedAt: Date()
        )

        try await workspace.save(note: note)
        let refreshed = try await libraryService.refresh(settings: settings).first!

        XCTAssertEqual(refreshed.note?.chineseName, "示例技能")
        XCTAssertEqual(refreshed.skill.contentHash, original.skill.contentHash)
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: skillDirectory.appendingPathComponent(".skilldock.json").path
            )
        )
    }

    func testImportAndInstallCopySkillsToConfiguredLocations() async throws {
        let source = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: source)
        let settings = SkillSettings(
            libraryPath: try Fixtures.temporaryDirectory(),
            codexPath: try Fixtures.temporaryDirectory(),
            claudePath: try Fixtures.temporaryDirectory()
        )
        let workspace = SkillWorkspaceService()

        _ = try await workspace.importSkill(
            from: source,
            settings: settings,
            strategy: .skip
        )
        _ = try await workspace.installSkill(
            from: source,
            target: .codex,
            settings: settings,
            strategy: .skip
        )

        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: settings.libraryPath
                    .appendingPathComponent(source.lastPathComponent)
                    .appendingPathComponent("SKILL.md").path
            )
        )
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: settings.codexPath
                    .appendingPathComponent(source.lastPathComponent)
                    .appendingPathComponent("SKILL.md").path
            )
        )
    }

    func testUninstallRemovesOnlySelectedAgentCopy() async throws {
        let library = try Fixtures.temporaryDirectory()
        let codex = try Fixtures.temporaryDirectory()
        let claude = try Fixtures.temporaryDirectory()
        let name = "sample-skill"
        try Fixtures.makeSkill(at: library.appendingPathComponent(name))
        try Fixtures.makeSkill(at: codex.appendingPathComponent(name))
        try Fixtures.makeSkill(at: claude.appendingPathComponent(name))
        let settings = SkillSettings(
            libraryPath: library,
            codexPath: codex,
            claudePath: claude
        )

        try await SkillWorkspaceService().uninstallSkill(
            named: name,
            target: .codex,
            settings: settings
        )

        XCTAssertTrue(FileManager.default.fileExists(
            atPath: library.appendingPathComponent(name).path
        ))
        XCTAssertFalse(FileManager.default.fileExists(
            atPath: codex.appendingPathComponent(name).path
        ))
        XCTAssertTrue(FileManager.default.fileExists(
            atPath: claude.appendingPathComponent(name).path
        ))
    }

    func testUninstallDoesNotModifyLibraryOrNotes() async throws {
        let library = try Fixtures.temporaryDirectory()
        let codex = try Fixtures.temporaryDirectory()
        let notesDirectory = try Fixtures.temporaryDirectory()
        let name = "sample-skill"
        try Fixtures.makeSkill(at: library.appendingPathComponent(name))
        try Fixtures.makeSkill(at: codex.appendingPathComponent(name))
        let notesStore = NotesStore(directory: notesDirectory)
        try await notesStore.upsert(
            SkillNote(
                key: SkillNoteKey(
                    name: name,
                    source: .library,
                    contentHash: "hash"
                ),
                chineseName: "示例技能",
                chineseDescription: "中文说明",
                tags: [],
                useCases: [],
                riskLevel: .low,
                riskNote: "",
                usageNote: "",
                updatedAt: Date()
            )
        )
        let libraryBefore = try Fixtures.snapshot(directory: library)
        let notesBefore = try Fixtures.snapshot(directory: notesDirectory)
        let settings = SkillSettings(
            libraryPath: library,
            codexPath: codex,
            claudePath: try Fixtures.temporaryDirectory()
        )

        try await SkillWorkspaceService(notesStore: notesStore).uninstallSkill(
            named: name,
            target: .codex,
            settings: settings
        )

        XCTAssertEqual(try Fixtures.snapshot(directory: library), libraryBefore)
        XCTAssertEqual(try Fixtures.snapshot(directory: notesDirectory), notesBefore)
        XCTAssertFalse(FileManager.default.fileExists(
            atPath: codex.appendingPathComponent(name).path
        ))
    }

    func testUninstallRejectsSystemSkill() async throws {
        let codex = try Fixtures.temporaryDirectory()
        let name = "sample-skill"
        let installedSkill = codex.appendingPathComponent(name)
        try Fixtures.makeSkill(at: installedSkill)
        let settings = SkillSettings(
            libraryPath: try Fixtures.temporaryDirectory(),
            codexPath: codex,
            claudePath: try Fixtures.temporaryDirectory()
        )

        do {
            try await SkillWorkspaceService().uninstallSkill(
                named: name,
                target: .codex,
                settings: settings,
                isSystemSkill: true
            )
            XCTFail("Expected system skill rejection")
        } catch {
            XCTAssertEqual(error as? SkillFileOperationError, .systemSkillIsReadOnly)
        }

        XCTAssertTrue(FileManager.default.fileExists(atPath: installedSkill.path))
    }

    func testUninstallRejectsAgentRootResolvingToLibrary() async throws {
        let parent = try Fixtures.temporaryDirectory()
        let library = parent.appendingPathComponent("library", isDirectory: true)
        let linkedAgentRoot = parent.appendingPathComponent("agent-link", isDirectory: true)
        let normalizedAgentRoot = library.appendingPathComponent("../library", isDirectory: true)
        let name = "sample-skill"
        try Fixtures.makeSkill(at: library.appendingPathComponent(name))
        try FileManager.default.createSymbolicLink(
            at: linkedAgentRoot,
            withDestinationURL: library
        )
        let libraryBefore = try Fixtures.snapshot(directory: library)

        for agentRoot in [linkedAgentRoot, normalizedAgentRoot] {
            let settings = SkillSettings(
                libraryPath: library,
                codexPath: agentRoot,
                claudePath: try Fixtures.temporaryDirectory()
            )

            do {
                try await SkillWorkspaceService().uninstallSkill(
                    named: name,
                    target: .codex,
                    settings: settings
                )
                XCTFail("Expected Library target rejection")
            } catch {
                XCTAssertEqual(error as? SkillFileOperationError, .destinationOutsideRoot)
            }

            XCTAssertEqual(try Fixtures.snapshot(directory: library), libraryBefore)
        }
    }

    func testConfirmedImportUsesPreviewStrategyAndReturnsDestination() async throws {
        let source = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: source)
        let settings = SkillSettings(
            libraryPath: try Fixtures.temporaryDirectory(),
            codexPath: try Fixtures.temporaryDirectory(),
            claudePath: try Fixtures.temporaryDirectory()
        )
        let preview = ImportPreview(
            sourceURL: source,
            name: "sample-skill",
            description: nil,
            relativePaths: ["SKILL.md"],
            fileCount: 1,
            hasScripts: false,
            hasConflict: false,
            strategy: .skip
        )

        let result = try await SkillWorkspaceService().importSkill(
            preview: preview,
            settings: settings
        )

        guard case let .copied(destination) = result else {
            return XCTFail("Expected copied result")
        }
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: destination.appendingPathComponent("SKILL.md").path
            )
        )
    }

    func testSavingDraftCreatesCompleteNoteWithoutChangingSkillHash() async throws {
        let skillDirectory = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: skillDirectory)
        let originalHash = try SkillHasher().hash(directory: skillDirectory)
        let notesStore = NotesStore(directory: try Fixtures.temporaryDirectory())
        let service = SkillWorkspaceService(notesStore: notesStore)
        let skill = Skill(
            id: "sample",
            name: "sample-skill",
            description: nil,
            path: skillDirectory,
            source: .library,
            hasScripts: false,
            isSystem: false,
            isReadOnly: false,
            contentHash: originalHash
        )
        var draft = NoteDraft(note: nil)
        draft.chineseName = "示例技能"
        draft.tags = ["示例"]
        draft.useCases = ["测试"]

        try await service.save(draft: draft, for: skill)

        let saved = try await notesStore.load().first
        XCTAssertEqual(saved?.chineseName, "示例技能")
        XCTAssertEqual(saved?.useCases, ["测试"])
        XCTAssertEqual(try SkillHasher().hash(directory: skillDirectory), originalHash)
    }
}
