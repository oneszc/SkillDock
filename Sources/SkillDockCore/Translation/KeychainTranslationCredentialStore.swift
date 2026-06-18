import Foundation
import Security

protocol KeychainAccessing: Sendable {
    func data(service: String, account: String) throws -> Data?
    func save(_ data: Data, service: String, account: String) throws
    func delete(service: String, account: String) throws
}

public actor KeychainTranslationCredentialStore: TranslationCredentialStoring {
    private static let service = "com.oneszc.SkillDock.translation"
    private let client: any KeychainAccessing

    public init() {
        client = SecurityKeychainClient()
    }

    init(client: any KeychainAccessing) {
        self.client = client
    }

    public func apiKey(providerID: String) throws -> String? {
        guard let data = try client.data(service: Self.service, account: providerID) else {
            return nil
        }
        guard let apiKey = String(data: data, encoding: .utf8) else {
            throw TranslationCredentialError.unreadableCredential
        }
        return apiKey
    }

    public func saveAPIKey(_ apiKey: String, providerID: String) throws {
        let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            try deleteAPIKey(providerID: providerID)
            return
        }
        try client.save(Data(trimmed.utf8), service: Self.service, account: providerID)
    }

    public func deleteAPIKey(providerID: String) throws {
        try client.delete(service: Self.service, account: providerID)
    }
}

private struct SecurityKeychainClient: KeychainAccessing {
    func data(service: String, account: String) throws -> Data? {
        var result: CFTypeRef?
        let status = SecItemCopyMatching(
            baseQuery(service: service, account: account).merging([
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]) { _, new in new } as CFDictionary,
            &result
        )
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else {
            throw TranslationCredentialError.keychainFailure
        }
        return data
    }

    func save(_ data: Data, service: String, account: String) throws {
        let query = baseQuery(service: service, account: account)
        let updateStatus = SecItemUpdate(
            query as CFDictionary,
            [kSecValueData as String: data] as CFDictionary
        )
        if updateStatus == errSecSuccess { return }
        guard updateStatus == errSecItemNotFound else {
            throw TranslationCredentialError.keychainFailure
        }

        let addStatus = SecItemAdd(
            query.merging([
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
            ]) { _, new in new } as CFDictionary,
            nil
        )
        guard addStatus == errSecSuccess else {
            throw TranslationCredentialError.keychainFailure
        }
    }

    func delete(service: String, account: String) throws {
        let status = SecItemDelete(baseQuery(service: service, account: account) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw TranslationCredentialError.keychainFailure
        }
    }

    private func baseQuery(service: String, account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
