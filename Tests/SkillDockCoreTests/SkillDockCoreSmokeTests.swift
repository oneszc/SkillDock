import XCTest
@testable import SkillDockCore

final class SkillDockCoreSmokeTests: XCTestCase {
    func testCoreModuleLoads() {
        XCTAssertEqual(SkillSource.library.displayName, "Library")
    }
}
