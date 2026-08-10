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
}
