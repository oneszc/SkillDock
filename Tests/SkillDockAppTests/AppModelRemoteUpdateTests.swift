import Foundation
import SkillDockCore
import XCTest
@testable import SkillDockApp

@MainActor
final class AppModelRemoteUpdateTests: XCTestCase {
    func testCheckSelectedRemoteUpdateStoresUpdateWithoutModifyingFiles() async throws {
        let fixture = try await makeUpdateFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        try Data("# Remote version".utf8)
            .write(to: fixture.remoteSkill.appendingPathComponent("SKILL.md"))
        let originalMarkdown = try String(
            contentsOf: fixture.localSkill.appendingPathComponent("SKILL.md"),
            encoding: .utf8
        )
        let model = AppModel(
            settingsStore: SettingsStore(directory: fixture.root.appendingPathComponent("settings")),
            libraryService: SkillLibraryService(notesStore: NotesStore(directory: fixture.root)),
            workspaceService: SkillWorkspaceService(notesStore: NotesStore(directory: fixture.root)),
            remoteUpdateService: fixture.updateService
        )
        model.settings = SkillSettings(
            libraryPath: fixture.localSkill.deletingLastPathComponent(),
            codexPath: fixture.root.appendingPathComponent("codex"),
            claudePath: fixture.root.appendingPathComponent("claude")
        )
        model.records = [fixture.record]
        model.selectionID = fixture.record.id

        await model.checkSelectedRemoteUpdate()

        XCTAssertEqual(model.remoteUpdate?.status, .updateAvailable)
        XCTAssertEqual(
            try String(
                contentsOf: fixture.localSkill.appendingPathComponent("SKILL.md"),
                encoding: .utf8
            ),
            originalMarkdown
        )
    }

    func testConfirmRemoteReplacementUpdatesFilesAndClearsUpdate() async throws {
        let fixture = try await makeUpdateFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        try Data("# Remote version".utf8)
            .write(to: fixture.remoteSkill.appendingPathComponent("SKILL.md"))
        let model = AppModel(
            settingsStore: SettingsStore(directory: fixture.root.appendingPathComponent("settings")),
            libraryService: SkillLibraryService(notesStore: NotesStore(directory: fixture.root)),
            workspaceService: SkillWorkspaceService(notesStore: NotesStore(directory: fixture.root)),
            remoteUpdateService: fixture.updateService
        )
        model.settings = SkillSettings(
            libraryPath: fixture.localSkill.deletingLastPathComponent(),
            codexPath: fixture.root.appendingPathComponent("codex"),
            claudePath: fixture.root.appendingPathComponent("claude")
        )
        model.records = [fixture.record]
        model.selectionID = fixture.record.id
        await model.checkSelectedRemoteUpdate()

        await model.confirmRemoteReplacement()

        XCTAssertNil(model.remoteUpdate)
        XCTAssertEqual(model.operationMessage, "Updated example.")
        XCTAssertEqual(
            try String(
                contentsOf: fixture.localSkill.appendingPathComponent("SKILL.md"),
                encoding: .utf8
            ),
            "# Remote version"
        )
    }

    private func makeUpdateFixture() async throws -> UpdateFixture {
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(".build/test-tmp/\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let localSkill = root.appendingPathComponent("library/example", isDirectory: true)
        try FileManager.default.createDirectory(
            at: localSkill.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try makeSkill(at: localSkill, name: "example")
        let remoteRoot = root.appendingPathComponent("remote", isDirectory: true)
        let remoteSkill = remoteRoot.appendingPathComponent("skills/example")
        try FileManager.default.createDirectory(
            at: remoteSkill.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try FileManager.default.copyItem(at: localSkill, to: remoteSkill)
        let hash = try SkillHasher().hash(directory: localSkill)
        let source = RemoteSkillSource(
            destination: localSkill,
            skillName: "example",
            repositoryURL: URL(string: "https://github.com/owner/repository")!,
            owner: "owner",
            repository: "repository",
            branch: "main",
            repositoryRelativePath: "skills/example",
            requestedMethod: .automatic,
            actualMethod: .gitClone,
            commit: "abc123",
            installedContentHash: hash
        )
        let repository = RemoteRepository(
            reference: GitHubRepositoryReference(
                owner: "owner",
                repository: "repository",
                branch: "main"
            ),
            localRoot: remoteRoot,
            method: .gitClone,
            commit: "def456",
            requiresCleanup: false
        )
        let sourceStore = RemoteSourceStore(directory: root.appendingPathComponent("app-support"))
        try await sourceStore.save([source])
        let updateService = RemoteUpdateService(
            repositoryService: RemoteRepositoryService(
                cloneProvider: StubRepositoryProvider(repository: repository),
                zipProvider: StubRepositoryProvider(repository: repository)
            ),
            sourceStore: sourceStore
        )
        let skill = Skill(
            id: "library:example",
            name: "example",
            description: "Sample description",
            path: localSkill,
            source: .library,
            hasScripts: false,
            isSystem: false,
            isReadOnly: false,
            contentHash: hash
        )
        return UpdateFixture(
            root: root,
            localSkill: localSkill,
            remoteSkill: remoteSkill,
            record: SkillRecord(
                skill: skill,
                note: nil,
                isNoteStale: false,
                remoteSource: source
            ),
            updateService: updateService
        )
    }

    private func makeSkill(at directory: URL, name: String) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data("""
        ---
        name: \(name)
        description: Sample description
        ---
        # Instructions
        """.utf8)
        .write(to: directory.appendingPathComponent("SKILL.md"))
    }
}

private struct UpdateFixture {
    let root: URL
    let localSkill: URL
    let remoteSkill: URL
    let record: SkillRecord
    let updateService: RemoteUpdateService
}

private actor StubRepositoryProvider: RemoteRepositoryProviding {
    let repository: RemoteRepository

    init(repository: RemoteRepository) {
        self.repository = repository
    }

    func acquire(_ reference: GitHubRepositoryReference) async throws -> RemoteRepository {
        repository
    }
}
