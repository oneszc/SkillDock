import XCTest
@testable import SkillDockCore

final class SkillDockCoreSmokeTests: XCTestCase {
    func testCoreModuleLoads() {
        XCTAssertEqual(SkillSource.library.displayName, "Library")
    }

    func testAvailableSourceRoundTripsWithoutBecomingAgent() throws {
        let source = SkillSource.available(.personal)
        let data = try JSONEncoder().encode(source)
        let decoded = try JSONDecoder().decode(SkillSource.self, from: data)

        XCTAssertEqual(decoded, .available(.personal))
        XCTAssertEqual(decoded.rawValue, "available:personal")
        XCTAssertEqual(decoded.displayName, "Personal")
    }

    func testUnknownAvailableSourceDoesNotDecodeAsAgent() throws {
        let data = try XCTUnwrap("\"available:future\"".data(using: .utf8))

        XCTAssertThrowsError(try JSONDecoder().decode(SkillSource.self, from: data)) { error in
            guard case DecodingError.dataCorrupted = error else {
                return XCTFail("Expected dataCorrupted, got \(error)")
            }
        }
    }

    func testLegacyAgentStringStillDecodesAsAgent() throws {
        let data = try XCTUnwrap("\"custom-agent\"".data(using: .utf8))

        let decoded = try JSONDecoder().decode(SkillSource.self, from: data)

        XCTAssertEqual(decoded, .agent("custom-agent"))
    }
}
