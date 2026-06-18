import Foundation
import XCTest
@testable import SkillDockCore

final class TranslationCredentialStoreTests: XCTestCase {
    func testCredentialsAreIsolatedByProviderID() async throws {
        let client = RecordingKeychainClient()
        let store = KeychainTranslationCredentialStore(client: client)

        try await store.saveAPIKey("deepseek-secret", providerID: "deepseek")
        try await store.saveAPIKey("future-secret", providerID: "future-provider")

        let deepSeekKey = try await store.apiKey(providerID: "deepseek")
        let futureKey = try await store.apiKey(providerID: "future-provider")

        XCTAssertEqual(deepSeekKey, "deepseek-secret")
        XCTAssertEqual(futureKey, "future-secret")
        XCTAssertEqual(client.savedAccounts, ["deepseek", "future-provider"])
        XCTAssertTrue(client.savedServices.allSatisfy { $0 == "com.oneszc.SkillDock.translation" })
    }

    func testSavingBlankCredentialDeletesProviderItem() async throws {
        let client = RecordingKeychainClient()
        let store = KeychainTranslationCredentialStore(client: client)
        try await store.saveAPIKey("secret", providerID: "deepseek")

        try await store.saveAPIKey("   ", providerID: "deepseek")

        let savedKey = try await store.apiKey(providerID: "deepseek")

        XCTAssertNil(savedKey)
        XCTAssertEqual(client.deletedAccounts, ["deepseek"])
    }
}

private final class RecordingKeychainClient: KeychainAccessing, @unchecked Sendable {
    private let lock = NSLock()
    private var values: [String: Data] = [:]
    private(set) var savedAccounts: [String] = []
    private(set) var savedServices: [String] = []
    private(set) var deletedAccounts: [String] = []

    func data(service: String, account: String) throws -> Data? {
        lock.withLock { values[key(service: service, account: account)] }
    }

    func save(_ data: Data, service: String, account: String) throws {
        lock.withLock {
            values[key(service: service, account: account)] = data
            savedAccounts.append(account)
            savedServices.append(service)
        }
    }

    func delete(service: String, account: String) throws {
        lock.withLock {
            values.removeValue(forKey: key(service: service, account: account))
            deletedAccounts.append(account)
        }
    }

    private func key(service: String, account: String) -> String {
        "\(service):\(account)"
    }
}
