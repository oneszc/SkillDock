import XCTest
@testable import SkillDockCore

final class SkillMarkdownParserTests: XCTestCase {
    func testParsesNameAndDescriptionFromFrontmatter() throws {
        let markdown = """
        ---
        name: figma-use
        description: Use Figma designs in implementation.
        ---
        # Instructions
        """

        let metadata = try SkillMarkdownParser().parse(markdown)

        XCTAssertEqual(metadata.name, "figma-use")
        XCTAssertEqual(metadata.description, "Use Figma designs in implementation.")
    }

    func testFallsBackWhenFrontmatterIsMissing() throws {
        let metadata = try SkillMarkdownParser().parse("# Instructions")

        XCTAssertNil(metadata.name)
        XCTAssertNil(metadata.description)
    }

    func testHashChangesWhenSkillContentChanges() throws {
        let directory = try Fixtures.temporaryDirectory()
        let skillFile = directory.appendingPathComponent("SKILL.md")
        try Fixtures.write("# First", to: skillFile)
        let firstHash = try SkillHasher().hash(directory: directory)

        try Fixtures.write("# Second", to: skillFile)
        let secondHash = try SkillHasher().hash(directory: directory)

        XCTAssertNotEqual(firstHash, secondHash)
    }

    func testHashIgnoresDSStore() throws {
        let directory = try Fixtures.temporaryDirectory()
        try Fixtures.write("# Skill", to: directory.appendingPathComponent("SKILL.md"))
        let firstHash = try SkillHasher().hash(directory: directory)

        try Fixtures.write("metadata", to: directory.appendingPathComponent(".DS_Store"))
        let secondHash = try SkillHasher().hash(directory: directory)

        XCTAssertEqual(firstHash, secondHash)
    }

    func testHashIgnoresGitMetadataDirectory() throws {
        let directory = try Fixtures.temporaryDirectory()
        try Fixtures.write("# Skill", to: directory.appendingPathComponent("SKILL.md"))
        let firstHash = try SkillHasher().hash(directory: directory)

        try Fixtures.write("git log state", to: directory.appendingPathComponent(".git/logs/HEAD"))
        try Fixtures.write("git config", to: directory.appendingPathComponent(".git/config"))
        let secondHash = try SkillHasher().hash(directory: directory)

        XCTAssertEqual(firstHash, secondHash)
    }

    func testHashIncludesImportantHiddenFiles() throws {
        let directory = try Fixtures.temporaryDirectory()
        try Fixtures.write("# Skill", to: directory.appendingPathComponent("SKILL.md"))
        let firstHash = try SkillHasher().hash(directory: directory)

        try Fixtures.write(
            "configuration",
            to: directory.appendingPathComponent(".skill-config")
        )
        let secondHash = try SkillHasher().hash(directory: directory)

        XCTAssertNotEqual(firstHash, secondHash)
    }
}
