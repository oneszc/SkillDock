import XCTest
@testable import SkillDockCore

final class CommandRunnerTests: XCTestCase {
    func testReturnsStandardOutput() async throws {
        let output = try await CommandRunner().run(
            executable: URL(fileURLWithPath: "/usr/bin/printf"),
            arguments: ["hello"]
        )

        XCTAssertEqual(output.standardOutput, "hello")
        XCTAssertEqual(output.standardError, "")
    }

    func testThrowsForNonZeroExit() async {
        do {
            _ = try await CommandRunner().run(
                executable: URL(fileURLWithPath: "/usr/bin/false"),
                arguments: []
            )
            XCTFail("Expected command to fail")
        } catch let error as CommandRunnerError {
            guard case let .failed(executable, status, _) = error else {
                return XCTFail("Unexpected error \(error)")
            }
            XCTAssertEqual(executable, "/usr/bin/false")
            XCTAssertEqual(status, 1)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }
}
