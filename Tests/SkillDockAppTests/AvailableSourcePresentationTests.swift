import Foundation
import SkillDockCore
import XCTest
@testable import SkillDockApp

final class AvailableSourcePresentationTests: XCTestCase {
    func testBadgesIncludeAvailableSourcesAndAgentCopy() {
        let record = makeRecord(
            availableSources: [.personal, .system],
            installedAgentIDs: [AgentTargetID.codex]
        )

        XCTAssertEqual(
            AvailableSourcePresentation.badges(for: record),
            [.personal, .system, .agentCopy]
        )
    }

    func testAgentCopyDoesNotBecomeAvailableFilterSource() {
        let record = makeRecord(availableSources: [], installedAgentIDs: [AgentTargetID.codex])

        XCTAssertTrue(AvailableSourcePresentation.badges(for: record).contains(.agentCopy))
        XCTAssertTrue(record.availableSources.isEmpty)
    }

    private func makeRecord(
        availableSources: [AvailableSkillSource],
        installedAgentIDs: Set<String>
    ) -> SkillRecord {
        let availableCopies = availableSources.map { source in
            SkillPhysicalCopy(
                source: .available(source),
                path: URL(fileURLWithPath: "/tmp/\(source.rawValue)/sample-skill"),
                isSystem: source == .system,
                isReadOnly: true,
                contentHash: "same"
            )
        }
        let agentCopies = installedAgentIDs.map { id in
            SkillPhysicalCopy(
                source: .agent(id),
                path: URL(fileURLWithPath: "/tmp/\(id)/sample-skill"),
                isSystem: false,
                isReadOnly: false,
                contentHash: "same"
            )
        }
        let skill = Skill(
            id: "sample-skill:same",
            name: "sample-skill",
            description: nil,
            path: (availableCopies + agentCopies).first?.path ?? URL(fileURLWithPath: "/tmp/sample-skill"),
            source: (availableCopies + agentCopies).first?.source ?? .library,
            hasScripts: false,
            isSystem: false,
            isReadOnly: !availableCopies.isEmpty,
            contentHash: "same",
            installation: .init(agentIDs: installedAgentIDs)
        )
        return SkillRecord(
            skill: skill,
            note: nil,
            isNoteStale: false,
            physicalCopies: availableCopies + agentCopies
        )
    }
}
