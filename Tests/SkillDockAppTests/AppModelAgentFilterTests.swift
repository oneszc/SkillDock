import Foundation
import SkillDockCore
import XCTest
@testable import SkillDockApp

@MainActor
final class AppModelAgentFilterTests: XCTestCase {
    func testLibraryAgentFilterReturnsOnlySkillsInstalledInSelectedAgent() {
        let model = AppModel()
        model.navigationSection = .library
        model.records = [
            record(name: "codex-only", source: .library, installation: .init(codex: true)),
            record(name: "claude-only", source: .library, installation: .init(claude: true)),
            record(name: "not-installed", source: .library)
        ]

        model.agentFilter = .agent(id: AgentTargetID.codex)

        XCTAssertEqual(model.filteredRecords.map(\.skill.name), ["codex-only"])
    }

    func testInstalledAgentFilterReturnsOnlySelectedAgentInstallations() {
        let model = AppModel()
        model.navigationSection = .installed
        model.records = [
            record(name: "codex-only", source: .library, installation: .init(codex: true)),
            record(name: "claude-only", source: .library, installation: .init(claude: true)),
            record(name: "both", source: .library, installation: .init(codex: true, claude: true))
        ]

        model.agentFilter = .agent(id: AgentTargetID.claude)

        XCTAssertEqual(model.filteredRecords.map(\.skill.name), ["claude-only", "both"])
    }

    func testAgentFilterUsesDynamicAgentID() {
        let model = AppModel()
        model.navigationSection = .library
        model.records = [
            record(
                name: "gemini-skill",
                source: .library,
                installation: .init(agentIDs: [AgentTargetID.gemini])
            ),
            record(
                name: "codex-skill",
                source: .library,
                installation: .init(agentIDs: [AgentTargetID.codex])
            )
        ]

        model.agentFilter = .agent(id: AgentTargetID.gemini)

        XCTAssertEqual(model.filteredRecords.map(\.skill.name), ["gemini-skill"])
    }

    func testAvailableFiltersByPhysicalSource() {
        let model = AppModel()
        model.navigationSection = .available
        model.records = [
            record(name: "personal", source: .available(.personal)),
            record(name: "system", source: .available(.system)),
            record(name: "agent", source: .codex)
        ]

        model.availableSourceFilter = .personal
        XCTAssertEqual(model.filteredRecords.map(\.skill.name), ["personal"])

        model.availableSourceFilter = .system
        XCTAssertEqual(model.filteredRecords.map(\.skill.name), ["system"])

        model.availableSourceFilter = .all
        XCTAssertEqual(model.filteredRecords.map(\.skill.name), ["personal", "system"])
    }

    func testAvailableAllSourcesPrefersPersonalDetailCopy() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let personalPath = root.appendingPathComponent("personal/sample-skill")
        let systemPath = root.appendingPathComponent("system/sample-skill")
        try FileManager.default.createDirectory(at: personalPath, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: systemPath, withIntermediateDirectories: true)
        try Data("# Personal copy".utf8).write(to: personalPath.appendingPathComponent("SKILL.md"))
        try Data("# System copy".utf8).write(to: systemPath.appendingPathComponent("SKILL.md"))
        defer { try? FileManager.default.removeItem(at: root) }

        let personal = SkillPhysicalCopy(
            source: .available(.personal),
            path: personalPath,
            isSystem: false,
            isReadOnly: true,
            contentHash: "same"
        )
        let system = SkillPhysicalCopy(
            source: .available(.system),
            path: systemPath,
            isSystem: true,
            isReadOnly: true,
            contentHash: "same"
        )
        let record = record(
            name: "sample-skill",
            source: .available(.personal),
            physicalCopies: [system, personal]
        )
        let model = AppModel()
        model.records = [record]
        model.selectionID = record.id
        model.navigationSection = .available
        model.availableSourceFilter = .all

        await model.loadSelectedDetail()

        XCTAssertEqual(model.markdown, "# Personal copy")
        XCTAssertEqual(model.selectedRecord?.skill.source, .available(.personal))
        XCTAssertEqual(model.selectedRecord?.skill.isReadOnly, true)
    }

    func testAvailableSourceFiltersLoadMatchingPhysicalCopy() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let personalPath = root.appendingPathComponent("personal/sample-skill")
        let systemPath = root.appendingPathComponent("system/sample-skill")
        try FileManager.default.createDirectory(at: personalPath, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: systemPath, withIntermediateDirectories: true)
        try Data("# Personal copy".utf8).write(to: personalPath.appendingPathComponent("SKILL.md"))
        try Data("# System copy".utf8).write(to: systemPath.appendingPathComponent("SKILL.md"))
        defer { try? FileManager.default.removeItem(at: root) }

        let personal = SkillPhysicalCopy(
            source: .available(.personal),
            path: personalPath,
            isSystem: false,
            isReadOnly: true,
            contentHash: "same"
        )
        let system = SkillPhysicalCopy(
            source: .available(.system),
            path: systemPath,
            isSystem: true,
            isReadOnly: true,
            contentHash: "same"
        )
        let record = record(
            name: "sample-skill",
            source: .available(.personal),
            physicalCopies: [system, personal]
        )
        let model = AppModel()
        model.records = [record]
        model.selectionID = record.id
        model.navigationSection = .available

        model.availableSourceFilter = .personal
        await model.loadSelectedDetail()
        XCTAssertEqual(model.markdown, "# Personal copy")
        XCTAssertEqual(model.selectedRecord?.skill.source, .available(.personal))

        model.availableSourceFilter = .system
        await model.loadSelectedDetail()
        XCTAssertEqual(model.markdown, "# System copy")
        XCTAssertEqual(model.selectedRecord?.skill.source, .available(.system))
    }

    func testAvailableSourceFilterChangesDetailContextWhenSelectionIsPreserved() {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let personal = SkillPhysicalCopy(
            source: .available(.personal),
            path: root.appendingPathComponent("personal/sample-skill"),
            isSystem: false,
            isReadOnly: true,
            contentHash: "same"
        )
        let system = SkillPhysicalCopy(
            source: .available(.system),
            path: root.appendingPathComponent("system/sample-skill"),
            isSystem: true,
            isReadOnly: true,
            contentHash: "same"
        )
        let record = record(
            name: "sample-skill",
            source: .available(.personal),
            physicalCopies: [personal, system]
        )
        let model = AppModel()
        model.records = [record]
        model.selectionID = record.id
        model.navigationSection = .available
        model.availableSourceFilter = .personal
        let personalContext = model.selectedDetailContextID

        model.availableSourceFilter = .system

        XCTAssertEqual(model.selectionID, record.id)
        XCTAssertNotEqual(model.selectedDetailContextID, personalContext)
    }

    func testLibraryContextKeepsMergedLibraryCopyWritable() {
        let library = SkillPhysicalCopy(
            source: .library,
            path: URL(fileURLWithPath: "/tmp/library/sample-skill"),
            isSystem: false,
            isReadOnly: false,
            contentHash: "same"
        )
        let personal = SkillPhysicalCopy(
            source: .available(.personal),
            path: URL(fileURLWithPath: "/tmp/personal/sample-skill"),
            isSystem: false,
            isReadOnly: true,
            contentHash: "same"
        )
        let merged = record(
            name: "sample-skill",
            source: .library,
            physicalCopies: [library, personal]
        )
        let model = AppModel()
        model.records = [merged]
        model.selectionID = merged.id
        model.navigationSection = .library

        XCTAssertEqual(model.selectedRecord?.skill.source, .library)
        XCTAssertEqual(model.selectedRecord?.skill.isReadOnly, false)
    }

    func testAvailableSystemContextUsesLegacyTranslationWithoutChangingBaseContexts() throws {
        let library = mergedSkill(source: .library)
        let installed = mergedSkill(source: .codex)
        let system = mergedSkill(
            source: .available(.system),
            isSystem: true,
            isReadOnly: true
        )
        let legacyTranslation = SkillTranslation(
            skillName: library.name,
            source: .codex,
            contentHash: library.contentHash,
            translatedDescription: "Legacy system translation",
            translatedMarkdown: "# Legacy system translation",
            providerID: TranslationProviderID.deepSeek,
            model: DeepSeekModel.flash.rawValue,
            generatedAt: Date(timeIntervalSince1970: 1)
        )
        let merged = try XCTUnwrap(
            SkillLibraryBuilder().build(
                skills: [library, installed, system],
                notes: [],
                translations: [legacyTranslation]
            ).first
        )
        let model = AppModel()
        model.records = [merged]
        model.selectionID = merged.id

        model.navigationSection = .library
        XCTAssertNil(model.selectedRecord?.translation)

        model.navigationSection = .installed
        XCTAssertNil(model.selectedRecord?.translation)

        model.navigationSection = .available
        model.availableSourceFilter = .system
        XCTAssertEqual(model.selectedRecord?.skill.source, .available(.system))
        XCTAssertEqual(model.selectedRecord?.translation, legacyTranslation)
        XCTAssertEqual(model.selectedRecord?.isTranslationStale, false)
    }

    func testAgentOnlyIsNotAvailableAndAvailableOnlyIsNotInstalled() {
        let model = AppModel()
        model.records = [
            record(name: "agent", source: .codex, installation: .init(codex: true)),
            record(name: "personal", source: .available(.personal))
        ]

        model.navigationSection = .available
        XCTAssertEqual(model.filteredRecords.map(\.skill.name), ["personal"])

        model.navigationSection = .installed
        XCTAssertEqual(model.filteredRecords.map(\.skill.name), ["agent"])
    }

    func testAvailableFilterSelectsFirstVisibleRecordWhenItHidesSelection() {
        let model = AppModel()
        let personal = record(name: "personal", source: .available(.personal))
        let system = record(name: "system", source: .available(.system))
        model.records = [personal, system]
        model.navigationSection = .available
        model.selectionID = system.id

        model.availableSourceFilter = .personal

        XCTAssertEqual(model.selectionID, personal.id)
    }

    func testAvailableNavigationSelectsFirstVisibleRecord() {
        let model = AppModel()
        let agent = record(name: "agent", source: .codex)
        let personal = record(name: "personal", source: .available(.personal))
        model.records = [agent, personal]
        model.selectionID = agent.id

        model.navigationSection = .available

        XCTAssertEqual(model.selectionID, personal.id)
    }

    func testRefreshClearsAvailableSelectionWhenSelectedRecordLosesAvailableCopy() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let home = root.appendingPathComponent("home")
        let library = root.appendingPathComponent("library")
        let personal = home.appendingPathComponent(".agents/skills/sample-skill")
        let settingsDirectory = root.appendingPathComponent("settings")
        let notesDirectory = root.appendingPathComponent("notes")
        let librarySkill = library.appendingPathComponent("sample-skill")
        try FileManager.default.createDirectory(at: personal, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: librarySkill, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: settingsDirectory, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: notesDirectory, withIntermediateDirectories: true)
        try Data("# Sample skill".utf8).write(to: personal.appendingPathComponent("SKILL.md"))
        try Data("# Sample skill".utf8).write(to: librarySkill.appendingPathComponent("SKILL.md"))
        defer { try? FileManager.default.removeItem(at: root) }

        var settings = SkillSettings.defaults(homeDirectory: home)
        settings.libraryPath = library
        let model = AppModel(
            settingsStore: SettingsStore(directory: settingsDirectory, defaultSettings: settings),
            libraryService: SkillLibraryService(
                notesStore: NotesStore(directory: notesDirectory),
                homeDirectory: home
            )
        )
        model.settings = settings
        model.navigationSection = .available
        model.availableSourceFilter = .personal

        await model.refresh()
        XCTAssertEqual(model.selectedRecord?.skill.source, .available(.personal))

        try FileManager.default.removeItem(at: personal)
        await model.refresh()

        XCTAssertNil(model.selectionID)
        XCTAssertNil(model.selectedRecord)
        XCTAssertTrue(model.filteredRecords.isEmpty)
    }

    private func record(
        name: String,
        source: SkillSource,
        installation: SkillInstallation = .init(),
        physicalCopies: [SkillPhysicalCopy] = []
    ) -> SkillRecord {
        SkillRecord(
            skill: Skill(
                id: "\(source.rawValue):\(name)",
                name: name,
                description: nil,
                path: URL(fileURLWithPath: "/tmp/\(name)"),
                source: source,
                hasScripts: false,
                isSystem: false,
                isReadOnly: false,
                contentHash: name,
                installation: installation
            ),
            note: nil,
            isNoteStale: false,
            physicalCopies: physicalCopies
        )
    }

    private func mergedSkill(
        source: SkillSource,
        isSystem: Bool = false,
        isReadOnly: Bool = false
    ) -> Skill {
        Skill(
            id: "\(source.rawValue):merged-skill:same",
            name: "merged-skill",
            description: nil,
            path: URL(fileURLWithPath: "/tmp/\(source.rawValue)/merged-skill"),
            source: source,
            hasScripts: false,
            isSystem: isSystem,
            isReadOnly: isReadOnly,
            contentHash: "same"
        )
    }
}
