import Foundation

public protocol TranslationCredentialStoring: Sendable {
    func apiKey(providerID: String) async throws -> String?
    func saveAPIKey(_ apiKey: String, providerID: String) async throws
    func deleteAPIKey(providerID: String) async throws
}

enum TranslationCredentialError: LocalizedError {
    case unreadableCredential
    case keychainFailure

    var errorDescription: String? {
        switch self {
        case .unreadableCredential:
            "The saved API key could not be read."
        case .keychainFailure:
            "The API key could not be saved in Keychain."
        }
    }
}
