import XCTest
@testable import SkillDockApp
@testable import SkillDockCore

@MainActor
final class RemoteImportModelTests: XCTestCase {
    func testSelectAllAndDeselectAllCandidates() {
        let model = RemoteImportModel()
        model.candidates = [
            candidate(name: "first", selected: false),
            candidate(name: "second", selected: true)
        ]

        model.selectAllCandidates()
        XCTAssertEqual(model.selectedCount, 2)

        model.deselectAllCandidates()
        XCTAssertEqual(model.selectedCount, 0)
    }

    private func candidate(name: String, selected: Bool) -> RemoteSkillCandidate {
        RemoteSkillCandidate(
            sourceURL: URL(fileURLWithPath: "/tmp/\(name)"),
            repositoryRelativePath: "skills/\(name)",
            name: name,
            description: nil,
            contentHash: name,
            relativePaths: ["SKILL.md"],
            fileCount: 1,
            hasScripts: false,
            hasConflict: false,
            isSelected: selected
        )
    }
}
