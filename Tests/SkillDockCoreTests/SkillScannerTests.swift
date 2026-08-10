import XCTest
@testable import SkillDockCore

final class SkillScannerTests: XCTestCase {
    func testFindsNestedFoldersContainingSkillMarkdown() async throws {
        let root = try Fixtures.temporaryDirectory()
        let nestedSkill = root.appendingPathComponent("writing/article-writer")
        try Fixtures.makeSkill(at: nestedSkill, name: "article-writer")

        let result = await SkillScanner().scan([
            ScanLocation(root: root, source: .library)
        ])

        XCTAssertEqual(result.skills.map(\.name), ["article-writer"])
        XCTAssertEqual(
            result.skills.first?.path.resolvingSymlinksInPath(),
            nestedSkill.resolvingSymlinksInPath()
        )
    }

    func testIgnoresFoldersWithoutSkillMarkdown() async throws {
        let root = try Fixtures.temporaryDirectory()
        try Fixtures.write("readme", to: root.appendingPathComponent("README.md"))

        let result = await SkillScanner().scan([
            ScanLocation(root: root, source: .library)
        ])

        XCTAssertTrue(result.skills.isEmpty)
    }

    func testMarksSystemAvailableSkillReadOnly() async throws {
        let root = try Fixtures.temporaryDirectory()
        let skillDirectory = root.appendingPathComponent(".system/skill-creator")
        try Fixtures.makeSkill(at: skillDirectory, name: "skill-creator")

        let result = await SkillScanner().scan([
            ScanLocation(root: root, source: .available(.system))
        ])

        XCTAssertEqual(result.skills.first?.isSystem, true)
        XCTAssertEqual(result.skills.first?.isReadOnly, true)
    }

    func testFallsBackToFolderNameWhenNameCannotBeParsed() async throws {
        let root = try Fixtures.temporaryDirectory()
        let skillDirectory = root.appendingPathComponent("fallback-name")
        try Fixtures.makeSkill(at: skillDirectory, name: nil, description: nil)

        let result = await SkillScanner().scan([
            ScanLocation(root: root, source: .claude)
        ])

        XCTAssertEqual(result.skills.first?.name, "fallback-name")
    }

    func testMarksSkillWithScriptsDirectory() async throws {
        let root = try Fixtures.temporaryDirectory()
        let skillDirectory = root.appendingPathComponent("scripted-skill")
        try Fixtures.makeSkill(at: skillDirectory)
        try Fixtures.write(
            "#!/bin/sh",
            to: skillDirectory.appendingPathComponent("scripts/run.sh")
        )

        let result = await SkillScanner().scan([
            ScanLocation(root: root, source: .library)
        ])

        XCTAssertEqual(result.skills.first?.hasScripts, true)
    }

    func testDoesNotMarkSkillWithScriptsFile() async throws {
        let root = try Fixtures.temporaryDirectory()
        let skillDirectory = root.appendingPathComponent("scripts-file")
        try Fixtures.makeSkill(at: skillDirectory)
        try Fixtures.write(
            "not a directory",
            to: skillDirectory.appendingPathComponent("scripts")
        )

        let result = await SkillScanner().scan([
            ScanLocation(root: root, source: .library)
        ])

        XCTAssertEqual(result.skills.first?.hasScripts, false)
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

    func testScansSkillForDynamicAgentSource() async throws {
        let root = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: root.appendingPathComponent("sample-skill"))

        let result = await SkillScanner().scan([
            ScanLocation(root: root, source: .agent("gemini"))
        ])

        XCTAssertEqual(result.skills.first?.source, .agent("gemini"))
        XCTAssertEqual(result.skills.first?.installation.agentIDs, ["gemini"])
    }

    func testScansPersonalAsReadOnlyAvailableSource() async throws {
        let root = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: root.appendingPathComponent("personal-skill"))

        let result = await SkillScanner().scan([
            ScanLocation(root: root, source: .available(.personal))
        ])

        XCTAssertEqual(result.skills.first?.source, .available(.personal))
        XCTAssertEqual(result.skills.first?.isReadOnly, true)
        XCTAssertTrue(result.skills.first?.installation.agentIDs.isEmpty == true)
    }

    func testExcludesSystemRootFromAgentCopyScan() async throws {
        let root = try Fixtures.temporaryDirectory()
        let systemRoot = root.appendingPathComponent(".system")
        try Fixtures.makeSkill(at: root.appendingPathComponent("agent-copy"), name: "agent-copy")
        try Fixtures.makeSkill(
            at: systemRoot.appendingPathComponent("system-skill"),
            name: "system-skill"
        )

        let result = await SkillScanner().scan([
            ScanLocation(root: root, source: .codex, excludedRoots: [systemRoot]),
            ScanLocation(root: systemRoot, source: .available(.system))
        ])

        XCTAssertEqual(result.skills.first { $0.name == "agent-copy" }?.source, .codex)
        XCTAssertEqual(
            result.skills.first { $0.name == "system-skill" }?.source,
            .available(.system)
        )
        XCTAssertEqual(result.skills.first { $0.name == "system-skill" }?.isSystem, true)
    }

    func testExcludesSystemRootByPhysicalIdentity() async throws {
        let root = try Fixtures.temporaryDirectory()
        let systemRoot = root.appendingPathComponent(".system")
        let systemAlias = root.appendingPathComponent("system-alias")
        try Fixtures.makeSkill(at: root.appendingPathComponent("agent-copy"), name: "agent-copy")
        try Fixtures.makeSkill(
            at: systemRoot.appendingPathComponent("system-skill"),
            name: "system-skill"
        )
        try FileManager.default.createSymbolicLink(at: systemAlias, withDestinationURL: systemRoot)

        let result = await SkillScanner().scan([
            ScanLocation(root: root, source: .codex, excludedRoots: [systemAlias])
        ])

        XCTAssertEqual(result.skills.map(\.name), ["agent-copy"])
    }

    func testMissingRootProducesNoIssue() async {
        let root = URL(fileURLWithPath: "/tmp/skilldock-missing-source")
        let result = await SkillScanner().scan([
            ScanLocation(root: root, source: .available(.personal))
        ])

        XCTAssertTrue(result.skills.isEmpty)
        XCTAssertTrue(result.issues.isEmpty)
    }

    func testUnreadableRootKeepsSuccessfulSkillsAndReportsIssue() async throws {
        let readableRoot = try Fixtures.temporaryDirectory()
        let unreadableRoot = readableRoot.appendingPathComponent("unreadable")
        try Fixtures.makeSkill(
            at: readableRoot.appendingPathComponent("readable-skill"),
            name: "readable-skill"
        )
        try FileManager.default.createDirectory(at: unreadableRoot, withIntermediateDirectories: true)

        let scanner = SkillScanner(enumeratorProvider: { url, keys, _ in
            guard url.standardizedFileURL != unreadableRoot.standardizedFileURL else { return nil }
            return FileManager.default.enumerator(
                at: url,
                includingPropertiesForKeys: keys,
                options: []
            )
        })
        let result = await scanner.scan([
            ScanLocation(root: readableRoot, source: .library, excludedRoots: [unreadableRoot]),
            ScanLocation(root: unreadableRoot, source: .available(.personal))
        ])

        XCTAssertEqual(result.skills.map(\.name), ["readable-skill"])
        XCTAssertEqual(result.issues.map(\.source), [.available(.personal)])
    }

    func testTraversalErrorKeepsSuccessfulSkillsAndReportsIssue() async throws {
        let root = try Fixtures.temporaryDirectory()
        try Fixtures.makeSkill(at: root.appendingPathComponent("readable-skill"))

        let scanner = SkillScanner(enumeratorProvider: { url, keys, errorHandler in
            _ = errorHandler?(url.appendingPathComponent("blocked"), ScannerTestError.blocked)
            return FileManager.default.enumerator(
                at: url,
                includingPropertiesForKeys: keys,
                options: []
            )
        })
        let result = await scanner.scan([
            ScanLocation(root: root, source: .available(.personal))
        ])

        XCTAssertEqual(result.skills.map(\.name), ["sample-skill"])
        XCTAssertEqual(result.issues.map(\.source), [.available(.personal)])
        XCTAssertTrue(result.issues.first?.message.contains("Blocked during traversal.") == true)
    }
}

private enum ScannerTestError: LocalizedError {
    case blocked

    var errorDescription: String? {
        "Blocked during traversal."
    }
}
