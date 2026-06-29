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

    func testSystemSectionUsesPhysicalCopiesForMembership() {
        let model = AppModel()
        model.navigationSection = .system
        model.records = [
            record(
                name: "sample-skill",
                source: .library,
                installation: .init(codex: true, claude: true),
                physicalCopies: [
                    SkillPhysicalCopy(
                        source: .library,
                        path: URL(fileURLWithPath: "/tmp/library/sample-skill"),
                        isSystem: false,
                        isReadOnly: false,
                        contentHash: "same"
                    ),
                    SkillPhysicalCopy(
                        source: .codex,
                        path: URL(fileURLWithPath: "/tmp/codex/.system/sample-skill"),
                        isSystem: true,
                        isReadOnly: true,
                        contentHash: "same"
                    ),
                    SkillPhysicalCopy(
                        source: .claude,
                        path: URL(fileURLWithPath: "/tmp/claude/sample-skill"),
                        isSystem: false,
                        isReadOnly: false,
                        contentHash: "same"
                    )
                ]
            )
        ]

        XCTAssertEqual(model.filteredRecords.map(\.skill.name), ["sample-skill"])
        XCTAssertEqual(model.filteredRecords.first?.hasLibraryCopy, true)
        XCTAssertEqual(model.filteredRecords.first?.hasInstalledCopy, true)
        XCTAssertEqual(model.filteredRecords.first?.hasSystemCopy, true)
    }

    func testSystemDetailLoadsSystemCopyContent() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        let libraryPath = root.appendingPathComponent("library/sample-skill")
        let systemPath = root.appendingPathComponent("codex/.system/sample-skill")
        try FileManager.default.createDirectory(at: libraryPath, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: systemPath, withIntermediateDirectories: true)
        try Data("# Library copy".utf8).write(to: libraryPath.appendingPathComponent("SKILL.md"))
        try Data("# System copy".utf8).write(to: systemPath.appendingPathComponent("SKILL.md"))
        defer { try? FileManager.default.removeItem(at: root) }

        let model = AppModel()
        let skill = Skill(
            id: "library:sample-skill:same",
            name: "sample-skill",
            description: nil,
            path: libraryPath,
            source: .library,
            hasScripts: false,
            isSystem: false,
            isReadOnly: false,
            contentHash: "same",
            installation: .init(codex: true)
        )
        let record = SkillRecord(
            skill: skill,
            note: nil,
            isNoteStale: false,
            physicalCopies: [
                skill.physicalCopy,
                SkillPhysicalCopy(
                    source: .codex,
                    path: systemPath,
                    isSystem: true,
                    isReadOnly: true,
                    contentHash: "same"
                )
            ]
        )
        model.records = [record]
        model.selectionID = record.id
        model.navigationSection = .system

        await model.loadSelectedDetail()

        XCTAssertEqual(model.markdown, "# System copy")
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
}
