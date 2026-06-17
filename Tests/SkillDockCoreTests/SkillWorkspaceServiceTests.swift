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

    func testInstallSkillCopiesToDynamicAgentTargetPath() async throws {
        let source = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(
            at: source.appendingPathComponent("sample-skill"),
            name: "sample-skill"
        )
        let destination = try Fixtures.temporaryDirectory()
        let target = AgentTarget(
            id: AgentTargetID.gemini,
            displayName: "Gemini",
            path: destination,
            isEnabled: true
        )

        _ = try await SkillWorkspaceService().installSkill(
            from: source.appendingPathComponent("sample-skill"),
            target: target,
            strategy: .skip,
            isSystemSkill: false
        )

        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: destination
                    .appendingPathComponent("sample-skill/SKILL.md")
                    .path
            )
        )
    }

    func testUninstallRemovesOnlySelectedAgentCopy() async throws {
        let library = try Fixtures.temporaryDirectory()
        let codex = try Fixtures.temporaryDirectory()
        let claude = try Fixtures.temporaryDirectory()
        let name = "sample-skill"
        let librarySkill = library.appendingPathComponent(name)
        try Fixtures.makeSkill(at: librarySkill)
        try Fixtures.makeSkill(at: codex.appendingPathComponent(name))
        try Fixtures.makeSkill(at: claude.appendingPathComponent(name))
        let contentHash = try await scannedHash(
            in: codex,
            source: .codex,
            folderName: name
        )
        let settings = SkillSettings(
            libraryPath: library,
            codexPath: codex,
            claudePath: claude
        )

        try await SkillWorkspaceService().uninstallSkill(
            named: name,
            contentHash: contentHash,
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

    func testUninstallRemovesOnlyDynamicAgentCopy() async throws {
        let targetRoot = try Fixtures.temporaryDirectory()
        let otherRoot = try Fixtures.temporaryDirectory()
        let library = try Fixtures.temporaryDirectory()
        let name = "sample-skill"
        try Fixtures.makeSkill(at: targetRoot.appendingPathComponent(name), name: name)
        try Fixtures.makeSkill(at: otherRoot.appendingPathComponent(name), name: name)
        let scanned = await SkillScanner().scan([
            ScanLocation(root: targetRoot, source: .agent(AgentTargetID.gemini))
        ])
        let hash = try XCTUnwrap(scanned.first?.contentHash)
        let target = AgentTarget(
            id: AgentTargetID.gemini,
            displayName: "Gemini",
            path: targetRoot,
            isEnabled: true
        )
        let otherTarget = AgentTarget(
            id: AgentTargetID.openCode,
            displayName: "OpenCode",
            path: otherRoot,
            isEnabled: true
        )

        try await SkillWorkspaceService().uninstallSkill(
            named: name,
            contentHash: hash,
            target: target,
            libraryPath: library,
            allAgentTargets: [target, otherTarget],
            isSystemSkill: false
        )

        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: targetRoot.appendingPathComponent(name).path
            )
        )
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: otherRoot.appendingPathComponent(name).path
            )
        )
    }

    func testUninstallDoesNotModifyLibraryOrNotes() async throws {
        let library = try Fixtures.temporaryDirectory()
        let codex = try Fixtures.temporaryDirectory()
        let notesDirectory = try Fixtures.temporaryDirectory()
        let name = "sample-skill"
        let librarySkill = library.appendingPathComponent(name)
        try Fixtures.makeSkill(at: librarySkill)
        try Fixtures.makeSkill(at: codex.appendingPathComponent(name))
        let contentHash = try await scannedHash(
            in: codex,
            source: .codex,
            folderName: name
        )
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
            contentHash: contentHash,
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
        let contentHash = try await scannedHash(
            in: codex,
            source: .codex,
            folderName: name
        )
        let settings = SkillSettings(
            libraryPath: try Fixtures.temporaryDirectory(),
            codexPath: codex,
            claudePath: try Fixtures.temporaryDirectory()
        )

        do {
            try await SkillWorkspaceService().uninstallSkill(
                named: name,
                contentHash: contentHash,
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

    func testUninstallRejectsScannedCodexSystemSkillWhenCallerOmitsFlag() async throws {
        let codex = try Fixtures.temporaryDirectory()
        let name = "skill-creator"
        let installedSkill = codex.appendingPathComponent(".system/\(name)")
        try Fixtures.makeSkill(at: installedSkill, name: name)
        let contentHash = try await scannedHash(
            in: codex,
            source: .codex,
            folderName: name
        )
        let settings = SkillSettings(
            libraryPath: try Fixtures.temporaryDirectory(),
            codexPath: codex,
            claudePath: try Fixtures.temporaryDirectory()
        )

        do {
            try await SkillWorkspaceService().uninstallSkill(
                named: name,
                contentHash: contentHash,
                target: .codex,
                settings: settings
            )
            XCTFail("Expected scanned system skill rejection")
        } catch {
            XCTAssertEqual(error as? SkillFileOperationError, .systemSkillIsReadOnly)
        }

        XCTAssertTrue(FileManager.default.fileExists(atPath: installedSkill.path))
    }

    func testUninstallThrowsWhenExactAgentCopyDisappearsBeforeRemoval() async throws {
        let codex = try Fixtures.temporaryDirectory()
        let name = "sample-skill"
        let installedSkill = codex.appendingPathComponent(name)
        try Fixtures.makeSkill(at: installedSkill)
        let contentHash = try await scannedHash(
            in: codex,
            source: .codex,
            folderName: name
        )
        let settings = SkillSettings(
            libraryPath: try Fixtures.temporaryDirectory(),
            codexPath: codex,
            claudePath: try Fixtures.temporaryDirectory()
        )
        let workspace = SkillWorkspaceService(
            beforeUninstallFinalValidation: { target in
                try FileManager.default.removeItem(at: target)
            }
        )

        do {
            try await workspace.uninstallSkill(
                named: name,
                contentHash: contentHash,
                target: .codex,
                settings: settings
            )
            XCTFail("Expected disappeared installed skill rejection")
        } catch {
            XCTAssertEqual(error as? SkillWorkspaceServiceError, .installedSkillNotFound)
        }
    }

    func testUninstallDoesNotDeleteChangedAgentCopyBeforeRemoval() async throws {
        let codex = try Fixtures.temporaryDirectory()
        let name = "sample-skill"
        let installedSkill = codex.appendingPathComponent(name)
        try Fixtures.makeSkill(at: installedSkill)
        let contentHash = try await scannedHash(
            in: codex,
            source: .codex,
            folderName: name
        )
        let settings = SkillSettings(
            libraryPath: try Fixtures.temporaryDirectory(),
            codexPath: codex,
            claudePath: try Fixtures.temporaryDirectory()
        )
        let workspace = SkillWorkspaceService(
            beforeUninstallFinalValidation: { target in
                try Fixtures.write(
                    "replacement",
                    to: target.appendingPathComponent("replacement.txt")
                )
            }
        )

        do {
            try await workspace.uninstallSkill(
                named: name,
                contentHash: contentHash,
                target: .codex,
                settings: settings
            )
            XCTFail("Expected changed installed skill rejection")
        } catch {
            XCTAssertEqual(error as? SkillWorkspaceServiceError, .installedSkillNotFound)
        }

        XCTAssertTrue(FileManager.default.fileExists(atPath: installedSkill.path))
        XCTAssertEqual(
            try String(
                contentsOf: installedSkill.appendingPathComponent("replacement.txt"),
                encoding: .utf8
            ),
            "replacement"
        )
    }

    func testUninstallFindsExactAgentCopyWithDifferentFolderName() async throws {
        let library = try Fixtures.temporaryDirectory()
        let codex = try Fixtures.temporaryDirectory()
        let logicalName = "sample-skill"
        let librarySkill = library.appendingPathComponent(logicalName)
        let renamedAgentCopy = codex.appendingPathComponent("renamed-folder")
        let differentCopy = codex.appendingPathComponent("different-content")
        try Fixtures.makeSkill(at: librarySkill, name: logicalName)
        try Fixtures.makeSkill(at: renamedAgentCopy, name: logicalName)
        try Fixtures.makeSkill(at: differentCopy, name: logicalName, description: "Different")
        let contentHash = try await scannedHash(
            in: codex,
            source: .codex,
            folderName: renamedAgentCopy.lastPathComponent
        )
        let settings = SkillSettings(
            libraryPath: library,
            codexPath: codex,
            claudePath: try Fixtures.temporaryDirectory()
        )

        try await SkillWorkspaceService().uninstallSkill(
            named: logicalName,
            contentHash: contentHash,
            target: .codex,
            settings: settings
        )

        XCTAssertFalse(FileManager.default.fileExists(atPath: renamedAgentCopy.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: differentCopy.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: librarySkill.path))
    }

    func testUninstallThrowsWhenExactAgentCopyIsNotFound() async throws {
        let codex = try Fixtures.temporaryDirectory()
        let installedSkill = codex.appendingPathComponent("sample-skill")
        try Fixtures.makeSkill(at: installedSkill)
        let settings = SkillSettings(
            libraryPath: try Fixtures.temporaryDirectory(),
            codexPath: codex,
            claudePath: try Fixtures.temporaryDirectory()
        )

        do {
            try await SkillWorkspaceService().uninstallSkill(
                named: "sample-skill",
                contentHash: "different-hash",
                target: .codex,
                settings: settings
            )
            XCTFail("Expected exact installed skill not found error")
        } catch {
            XCTAssertEqual(error as? SkillWorkspaceServiceError, .installedSkillNotFound)
        }

        XCTAssertTrue(FileManager.default.fileExists(atPath: installedSkill.path))
    }

    func testUninstallRejectsAmbiguousExactAgentCopies() async throws {
        let codex = try Fixtures.temporaryDirectory()
        let firstCopy = codex.appendingPathComponent("first-copy")
        let secondCopy = codex.appendingPathComponent("second-copy")
        try Fixtures.makeSkill(at: firstCopy, name: "sample-skill")
        try Fixtures.makeSkill(at: secondCopy, name: "sample-skill")
        let contentHash = try await scannedHash(
            in: codex,
            source: .codex,
            folderName: firstCopy.lastPathComponent
        )
        let settings = SkillSettings(
            libraryPath: try Fixtures.temporaryDirectory(),
            codexPath: codex,
            claudePath: try Fixtures.temporaryDirectory()
        )

        do {
            try await SkillWorkspaceService().uninstallSkill(
                named: "sample-skill",
                contentHash: contentHash,
                target: .codex,
                settings: settings
            )
            XCTFail("Expected ambiguous installed skill rejection")
        } catch {
            XCTAssertEqual(error as? SkillWorkspaceServiceError, .installedSkillAmbiguous)
        }

        XCTAssertTrue(FileManager.default.fileExists(atPath: firstCopy.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: secondCopy.path))
    }

    func testUninstallRejectsAgentCopyEqualToLibrary() async throws {
        let parent = try Fixtures.temporaryDirectory()
        let library = parent.appendingPathComponent("library", isDirectory: true)
        let name = "sample-skill"
        try Fixtures.makeSkill(at: library, name: name)
        let contentHash = try await scannedHash(
            in: parent,
            source: .codex,
            folderName: library.lastPathComponent
        )
        let libraryBefore = try Fixtures.snapshot(directory: library)
        let settings = SkillSettings(
            libraryPath: library,
            codexPath: parent,
            claudePath: try Fixtures.temporaryDirectory()
        )

        do {
            try await SkillWorkspaceService().uninstallSkill(
                named: name,
                contentHash: contentHash,
                target: .codex,
                settings: settings
            )
            XCTFail("Expected Library overlap rejection")
        } catch {
            XCTAssertEqual(error as? SkillFileOperationError, .destinationOutsideRoot)
        }

        XCTAssertEqual(try Fixtures.snapshot(directory: library), libraryBefore)
    }

    func testUninstallRejectsAgentCopyInsideLibraryThroughSymbolicLink() async throws {
        let parent = try Fixtures.temporaryDirectory()
        let library = parent.appendingPathComponent("library", isDirectory: true)
        let installedSkill = library.appendingPathComponent("renamed-folder")
        let linkedAgentRoot = parent.appendingPathComponent("agent-link", isDirectory: true)
        let name = "sample-skill"
        try Fixtures.makeSkill(at: installedSkill, name: name)
        try FileManager.default.createSymbolicLink(at: linkedAgentRoot, withDestinationURL: library)
        let contentHash = try await scannedHash(
            in: library,
            source: .codex,
            folderName: installedSkill.lastPathComponent
        )
        let libraryBefore = try Fixtures.snapshot(directory: library)
        let settings = SkillSettings(
            libraryPath: library,
            codexPath: linkedAgentRoot,
            claudePath: try Fixtures.temporaryDirectory()
        )

        do {
            try await SkillWorkspaceService().uninstallSkill(
                named: name,
                contentHash: contentHash,
                target: .codex,
                settings: settings
            )
            XCTFail("Expected Library overlap rejection")
        } catch {
            XCTAssertEqual(error as? SkillFileOperationError, .destinationOutsideRoot)
        }

        XCTAssertEqual(try Fixtures.snapshot(directory: library), libraryBefore)
    }

    func testUninstallRejectsAgentCopyContainingLibrary() async throws {
        let parent = try Fixtures.temporaryDirectory()
        let installedSkill = parent.appendingPathComponent("agent-copy")
        let library = installedSkill.appendingPathComponent("library", isDirectory: true)
        let name = "sample-skill"
        try Fixtures.makeSkill(at: installedSkill, name: name)
        try Fixtures.write("keep", to: library.appendingPathComponent("sentinel.txt"))
        let contentHash = try await scannedHash(
            in: parent,
            source: .codex,
            folderName: installedSkill.lastPathComponent
        )
        let libraryBefore = try Fixtures.snapshot(directory: library)
        let settings = SkillSettings(
            libraryPath: library,
            codexPath: parent,
            claudePath: try Fixtures.temporaryDirectory()
        )

        do {
            try await SkillWorkspaceService().uninstallSkill(
                named: name,
                contentHash: contentHash,
                target: .codex,
                settings: settings
            )
            XCTFail("Expected Library overlap rejection")
        } catch {
            XCTAssertEqual(error as? SkillFileOperationError, .destinationOutsideRoot)
        }

        XCTAssertEqual(try Fixtures.snapshot(directory: library), libraryBefore)
    }

    func testUninstallAllowsAgentCopyBesideLibraryWithinSharedParent() async throws {
        let parent = try Fixtures.temporaryDirectory()
        let installedSkill = parent.appendingPathComponent("agent-copy")
        let library = parent.appendingPathComponent("library", isDirectory: true)
        let name = "sample-skill"
        try Fixtures.makeSkill(at: installedSkill, name: name)
        try Fixtures.write("keep", to: library.appendingPathComponent("sentinel.txt"))
        let contentHash = try await scannedHash(
            in: parent,
            source: .codex,
            folderName: installedSkill.lastPathComponent
        )
        let libraryBefore = try Fixtures.snapshot(directory: library)
        let settings = SkillSettings(
            libraryPath: library,
            codexPath: parent,
            claudePath: try Fixtures.temporaryDirectory()
        )

        try await SkillWorkspaceService().uninstallSkill(
            named: name,
            contentHash: contentHash,
            target: .codex,
            settings: settings
        )

        XCTAssertFalse(FileManager.default.fileExists(atPath: installedSkill.path))
        XCTAssertEqual(try Fixtures.snapshot(directory: library), libraryBefore)
    }

    func testUninstallRejectsSharedAgentRoot() async throws {
        let sharedAgentRoot = try Fixtures.temporaryDirectory()
        let installedSkill = sharedAgentRoot.appendingPathComponent("sample-skill")
        try Fixtures.makeSkill(at: installedSkill)
        let contentHash = try await scannedHash(
            in: sharedAgentRoot,
            source: .codex,
            folderName: installedSkill.lastPathComponent
        )
        let before = try Fixtures.snapshot(directory: sharedAgentRoot)
        let settings = SkillSettings(
            libraryPath: try Fixtures.temporaryDirectory(),
            codexPath: sharedAgentRoot,
            claudePath: sharedAgentRoot
        )

        do {
            try await SkillWorkspaceService().uninstallSkill(
                named: "sample-skill",
                contentHash: contentHash,
                target: .codex,
                settings: settings
            )
            XCTFail("Expected overlapping Agent path rejection")
        } catch {
            XCTAssertEqual(error as? SkillFileOperationError, .destinationOutsideRoot)
        }

        XCTAssertEqual(try Fixtures.snapshot(directory: sharedAgentRoot), before)
    }

    func testUninstallRejectsAgentCopyContainingOtherAgentRoot() async throws {
        let codexRoot = try Fixtures.temporaryDirectory()
        let installedSkill = codexRoot.appendingPathComponent("sample-skill")
        let claudeRoot = installedSkill.appendingPathComponent("claude", isDirectory: true)
        try Fixtures.makeSkill(at: installedSkill)
        try Fixtures.write("keep", to: claudeRoot.appendingPathComponent("sentinel.txt"))
        let contentHash = try await scannedHash(
            in: codexRoot,
            source: .codex,
            folderName: installedSkill.lastPathComponent
        )
        let before = try Fixtures.snapshot(directory: installedSkill)
        let settings = SkillSettings(
            libraryPath: try Fixtures.temporaryDirectory(),
            codexPath: codexRoot,
            claudePath: claudeRoot
        )

        do {
            try await SkillWorkspaceService().uninstallSkill(
                named: "sample-skill",
                contentHash: contentHash,
                target: .codex,
                settings: settings
            )
            XCTFail("Expected overlapping Agent path rejection")
        } catch {
            XCTAssertEqual(error as? SkillFileOperationError, .destinationOutsideRoot)
        }

        XCTAssertEqual(try Fixtures.snapshot(directory: installedSkill), before)
    }

    func testUninstallRejectsOtherAgentRootLinkedInsideTargetSkill() async throws {
        let parent = try Fixtures.temporaryDirectory()
        let codexRoot = parent.appendingPathComponent("codex", isDirectory: true)
        let installedSkill = codexRoot.appendingPathComponent("sample-skill")
        let claudeLink = parent.appendingPathComponent("claude-link", isDirectory: true)
        try Fixtures.makeSkill(at: installedSkill)
        try FileManager.default.createSymbolicLink(at: claudeLink, withDestinationURL: installedSkill)
        let contentHash = try await scannedHash(
            in: codexRoot,
            source: .codex,
            folderName: installedSkill.lastPathComponent
        )
        let before = try Fixtures.snapshot(directory: installedSkill)
        let settings = SkillSettings(
            libraryPath: try Fixtures.temporaryDirectory(),
            codexPath: codexRoot,
            claudePath: claudeLink
        )

        do {
            try await SkillWorkspaceService().uninstallSkill(
                named: "sample-skill",
                contentHash: contentHash,
                target: .codex,
                settings: settings
            )
            XCTFail("Expected overlapping Agent path rejection")
        } catch {
            XCTAssertEqual(error as? SkillFileOperationError, .destinationOutsideRoot)
        }

        XCTAssertEqual(try Fixtures.snapshot(directory: installedSkill), before)
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

    private func scannedHash(
        in root: URL,
        source: SkillSource,
        folderName: String
    ) async throws -> String {
        let skills = await SkillScanner().scan([ScanLocation(root: root, source: source)])
        return try XCTUnwrap(
            skills.first { $0.path.lastPathComponent == folderName }?.contentHash
        )
    }
}
