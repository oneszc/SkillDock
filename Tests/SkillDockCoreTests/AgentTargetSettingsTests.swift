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
}
