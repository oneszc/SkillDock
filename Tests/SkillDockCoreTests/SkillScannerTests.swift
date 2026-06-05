import XCTest
@testable import SkillDockCore

final class SkillScannerTests: XCTestCase {
    func testFindsNestedFoldersContainingSkillMarkdown() async throws {
        let root = try Fixtures.temporaryDirectory()
        let nestedSkill = root.appendingPathComponent("writing/article-writer")
        try Fixtures.makeSkill(at: nestedSkill, name: "article-writer")

        let skills = await SkillScanner().scan([
            ScanLocation(root: root, source: .library)
        ])

        XCTAssertEqual(skills.map(\.name), ["article-writer"])
        XCTAssertEqual(
            skills.first?.path.resolvingSymlinksInPath(),
            nestedSkill.resolvingSymlinksInPath()
        )
    }

    func testIgnoresFoldersWithoutSkillMarkdown() async throws {
        let root = try Fixtures.temporaryDirectory()
        try Fixtures.write("readme", to: root.appendingPathComponent("README.md"))

        let skills = await SkillScanner().scan([
            ScanLocation(root: root, source: .library)
        ])

        XCTAssertTrue(skills.isEmpty)
    }

    func testMarksCodexSystemSkillReadOnly() async throws {
        let root = try Fixtures.temporaryDirectory()
        let skillDirectory = root.appendingPathComponent(".system/skill-creator")
        try Fixtures.makeSkill(at: skillDirectory, name: "skill-creator")

        let skills = await SkillScanner().scan([
            ScanLocation(root: root, source: .codex)
        ])

        XCTAssertEqual(skills.first?.isSystem, true)
        XCTAssertEqual(skills.first?.isReadOnly, true)
    }

    func testFallsBackToFolderNameWhenNameCannotBeParsed() async throws {
        let root = try Fixtures.temporaryDirectory()
        let skillDirectory = root.appendingPathComponent("fallback-name")
        try Fixtures.makeSkill(at: skillDirectory, name: nil, description: nil)

        let skills = await SkillScanner().scan([
            ScanLocation(root: root, source: .claude)
        ])

        XCTAssertEqual(skills.first?.name, "fallback-name")
    }

    func testMarksSkillWithScriptsDirectory() async throws {
        let root = try Fixtures.temporaryDirectory()
        let skillDirectory = root.appendingPathComponent("scripted-skill")
        try Fixtures.makeSkill(at: skillDirectory)
        try Fixtures.write(
            "#!/bin/sh",
            to: skillDirectory.appendingPathComponent("scripts/run.sh")
        )

        let skills = await SkillScanner().scan([
            ScanLocation(root: root, source: .library)
        ])

        XCTAssertEqual(skills.first?.hasScripts, true)
    }

    func testDoesNotMarkSkillWithScriptsFile() async throws {
        let root = try Fixtures.temporaryDirectory()
        let skillDirectory = root.appendingPathComponent("scripts-file")
        try Fixtures.makeSkill(at: skillDirectory)
        try Fixtures.write(
            "not a directory",
            to: skillDirectory.appendingPathComponent("scripts")
        )

        let skills = await SkillScanner().scan([
            ScanLocation(root: root, source: .library)
        ])

        XCTAssertEqual(skills.first?.hasScripts, false)
    }

    func testScanDoesNotChangeOriginalSkillContent() async throws {
        let root = try Fixtures.temporaryDirectory()
        let skillDirectory = root.appendingPathComponent("read-only-scan")
        try Fixtures.makeSkill(at: skillDirectory)
        let skillFile = skillDirectory.appendingPathComponent("SKILL.md")
        let before = try Data(contentsOf: skillFile)

        _ = await SkillScanner().scan([
            ScanLocation(root: root, source: .library)
        ])

        XCTAssertEqual(try Data(contentsOf: skillFile), before)
    }
}
