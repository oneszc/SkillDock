import Foundation

protocol TranslationHTTPClient: Sendable {
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

struct URLSessionTranslationHTTPClient: TranslationHTTPClient {
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                throw TranslationProviderError.invalidResponse
            }
            return (data, response)
        } catch let error as TranslationProviderError {
            throw error
        } catch {
            throw TranslationProviderError.networkUnavailable
        }
    }
}
