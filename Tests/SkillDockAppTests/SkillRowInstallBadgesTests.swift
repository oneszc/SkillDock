import Foundation
import SkillDockCore
import XCTest
@testable import SkillDockApp

final class SkillRowInstallBadgesTests: XCTestCase {
    func testShowsAllInstalledAgentsWhenCountIsTwoOrLess() {
        let targets = [
            target(id: AgentTargetID.antigravity, name: "Antigravity"),
            target(id: AgentTargetID.gemini, name: "Gemini")
        ]

        let badges = SkillRowInstallBadges(installedTargets: targets)

        XCTAssertEqual(badges.visibleTargets.map(\.id), [AgentTargetID.antigravity, AgentTargetID.gemini])
        XCTAssertEqual(badges.collapsedCount, 0)
    }

    func testPrioritizesCodexAndClaudeWhenMoreThanTwoAgentsAreInstalled() {
        let targets = [
            target(id: AgentTargetID.antigravity, name: "Antigravity"),
            target(id: AgentTargetID.codex, name: "Codex"),
            target(id: AgentTargetID.claude, name: "Claude")
        ]

        let badges = SkillRowInstallBadges(installedTargets: targets)

        XCTAssertEqual(badges.visibleTargets.map(\.id), [AgentTargetID.codex, AgentTargetID.claude])
        XCTAssertEqual(badges.collapsedCount, 1)
    }

    func testFillsVisibleSlotsWithOtherAgentsWhenPreferredAgentsAreMissing() {
        let targets = [
            target(id: AgentTargetID.antigravity, name: "Antigravity"),
            target(id: AgentTargetID.gemini, name: "Gemini"),
            target(id: AgentTargetID.grok, name: "Grok")
        ]

        let badges = SkillRowInstallBadges(installedTargets: targets)

        XCTAssertEqual(badges.visibleTargets.map(\.id), [AgentTargetID.antigravity, AgentTargetID.gemini])
        XCTAssertEqual(badges.collapsedCount, 1)
    }

    private func target(id: String, name: String) -> AgentTarget {
        AgentTarget(
            id: id,
            displayName: name,
            path: URL(fileURLWithPath: "/tmp/\(id)"),
            isEnabled: true
        )
    }
}
