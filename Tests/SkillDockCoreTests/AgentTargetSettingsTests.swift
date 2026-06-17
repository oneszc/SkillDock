import Foundation
import XCTest
@testable import SkillDockCore

final class AgentTargetSettingsTests: XCTestCase {
    func testDefaultSettingsIncludeEnabledCodexAndClaudeTargets() {
        let home = URL(fileURLWithPath: "/Users/designer", isDirectory: true)
        let settings = SkillSettings.defaults(homeDirectory: home)

        XCTAssertEqual(settings.agentTargets.map(\.id), ["codex", "claude"])
        XCTAssertEqual(settings.agentTargets.map(\.isEnabled), [true, true])
        XCTAssertEqual(settings.agentTargets[0].path.path, "/Users/designer/.codex/skills")
        XCTAssertEqual(settings.agentTargets[1].path.path, "/Users/designer/.claude/skills")
    }

    func testAgentTargetsRoundTripThroughSettingsJSON() throws {
        var settings = SkillSettings.defaults(
            homeDirectory: URL(fileURLWithPath: "/Users/designer", isDirectory: true)
        )
        settings.agentTargets.append(
            AgentTarget(
                id: AgentTargetID.gemini,
                displayName: "Gemini",
                path: URL(fileURLWithPath: "/Users/designer/.gemini/skills", isDirectory: true),
                isEnabled: false
            )
        )

        let data = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(SkillSettings.self, from: data)

        XCTAssertEqual(decoded.agentTargets, settings.agentTargets)
    }
}
