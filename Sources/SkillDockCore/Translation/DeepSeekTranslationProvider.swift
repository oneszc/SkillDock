import Foundation

public struct DeepSeekTranslationProvider: TranslationProviding {
    public let id = TranslationProviderID.deepSeek

    private let endpoint = URL(string: "https://api.deepseek.com/chat/completions")!
    private let httpClient: any TranslationHTTPClient

    public init() {
        httpClient = URLSessionTranslationHTTPClient()
    }

    init(httpClient: any TranslationHTTPClient) {
        self.httpClient = httpClient
    }

    public func testConnection(apiKey: String, model: String) async throws {
        let body = ChatRequest(
            model: model,
            messages: [
                Message(role: "system", content: "Reply with OK."),
                Message(role: "user", content: "Connection test")
            ],
            responseFormat: nil
        )
        _ = try await perform(body, apiKey: apiKey)
    }

    public func translate(
        _ request: SkillTranslationRequest,
        apiKey: String,
        model: String
    ) async throws -> SkillTranslationOutput {
        let instructions = """
        Translate the supplied description and Markdown into Simplified Chinese.
        Return a JSON object with exactly two string fields: translatedDescription and translatedMarkdown.
        Preserve Markdown structure, headings, lists, tables, code blocks, links, commands, file paths, URLs, parameters, and identifiers.
        Do not add information or recommendations. Do not translate the Skill name: \(request.skillName).
        """
        let source = """
        Description:
        \(request.description)

        SKILL.md:
        \(request.markdown)
        """
        let body = ChatRequest(
            model: model,
            messages: [
                Message(role: "system", content: instructions),
                Message(role: "user", content: source)
            ],
            responseFormat: ResponseFormat(type: "json_object")
        )
        let response = try await perform(body, apiKey: apiKey)
        guard let content = response.choices.first?.message.content,
              let data = content.data(using: .utf8),
              let output = try? JSONDecoder().decode(SkillTranslationOutput.self, from: data),
              !output.translatedDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !output.translatedMarkdown.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            throw TranslationProviderError.invalidResponse
        }
        return output
    }

    private func perform(_ body: ChatRequest, apiKey: String) async throws -> ChatResponse {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await httpClient.data(for: request)
        switch response.statusCode {
        case 200..<300:
            guard let decoded = try? JSONDecoder().decode(ChatResponse.self, from: data) else {
                throw TranslationProviderError.invalidResponse
            }
            return decoded
        case 401, 403:
            throw TranslationProviderError.invalidAPIKey
        case 404:
            throw TranslationProviderError.modelUnavailable
        case 413:
            throw TranslationProviderError.contentTooLong
        default:
            throw TranslationProviderError.networkUnavailable
        }
    }
}

private struct ChatRequest: Encodable {
    let model: String
    let messages: [Message]
    let responseFormat: ResponseFormat?

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case responseFormat = "response_format"
    }
}

private struct Message: Codable {
    let role: String
    let content: String
}

private struct ResponseFormat: Encodable {
    let type: String
}

private struct ChatResponse: Decodable {
    let choices: [Choice]
}

private struct Choice: Decodable {
    let message: ResponseMessage
}

private struct ResponseMessage: Decodable {
    let content: String
}
