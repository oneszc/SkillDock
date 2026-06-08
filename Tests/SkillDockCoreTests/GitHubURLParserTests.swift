import XCTest
@testable import SkillDockCore

final class GitHubURLParserTests: XCTestCase {
    func testParsesRepositoryURL() throws {
        let reference = try GitHubURLParser().parse(
            "https://github.com/owner/repository"
        )

        XCTAssertEqual(reference.owner, "owner")
        XCTAssertEqual(reference.repository, "repository")
        XCTAssertNil(reference.branch)
        XCTAssertNil(reference.folderPath)
        XCTAssertEqual(
            reference.cloneURL.absoluteString,
            "https://github.com/owner/repository.git"
        )
    }

    func testParsesFolderURLWithBranchAndPath() throws {
        let reference = try GitHubURLParser().parse(
            "https://github.com/owner/repository/tree/main/skills/example-skill"
        )

        XCTAssertEqual(reference.owner, "owner")
        XCTAssertEqual(reference.repository, "repository")
        XCTAssertEqual(reference.branch, "main")
        XCTAssertEqual(reference.folderPath, "skills/example-skill")
    }

    func testNormalizesWWWHostAndGitSuffix() throws {
        let reference = try GitHubURLParser().parse(
            "https://www.github.com/owner/repository.git"
        )

        XCTAssertEqual(
            reference.repositoryURL.absoluteString,
            "https://github.com/owner/repository"
        )
    }

    func testRejectsUnsupportedAndIncompleteLinks() {
        XCTAssertThrowsError(
            try GitHubURLParser().parse("https://gitlab.com/owner/repository")
        ) {
            XCTAssertEqual($0 as? GitHubURLParserError, .unsupportedHost)
        }
        XCTAssertThrowsError(
            try GitHubURLParser().parse("https://github.com/owner")
        ) {
            XCTAssertEqual($0 as? GitHubURLParserError, .missingRepository)
        }
        XCTAssertThrowsError(
            try GitHubURLParser().parse("not a URL")
        ) {
            XCTAssertEqual($0 as? GitHubURLParserError, .invalidURL)
        }
    }
}
