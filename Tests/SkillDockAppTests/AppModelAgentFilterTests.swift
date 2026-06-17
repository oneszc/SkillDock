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

    private func record(
        name: String,
        source: SkillSource,
        installation: SkillInstallation = .init()
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
            isNoteStale: false
        )
    }
}
