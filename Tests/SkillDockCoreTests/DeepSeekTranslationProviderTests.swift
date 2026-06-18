import Foundation
import XCTest
@testable import SkillDockCore

final class DeepSeekTranslationProviderTests: XCTestCase {
    func testTranslateBuildsStructuredDeepSeekRequestAndParsesOutput() async throws {
        let outputJSON = """
        {"translatedDescription":"中文介绍","translatedMarkdown":"# 中文标题\\n\\n保留 `code`"}
        """
        let responseData = try JSONSerialization.data(withJSONObject: [
            "choices": [["message": ["content": outputJSON]]]
        ])
        let client = StubTranslationHTTPClient(statusCode: 200, data: responseData)
        let provider = DeepSeekTranslationProvider(httpClient: client)

        let output = try await provider.translate(
            SkillTranslationRequest(
                skillName: "sample-skill",
                description: "English description",
                markdown: "# English\n\nKeep `code`"
            ),
            apiKey: "secret-key",
            model: DeepSeekModel.flash.rawValue
        )

        XCTAssertEqual(output.translatedDescription, "中文介绍")
        XCTAssertEqual(output.translatedMarkdown, "# 中文标题\n\n保留 `code`")
        let capturedRequest = await client.lastRequest
        let request = try XCTUnwrap(capturedRequest)
        XCTAssertEqual(request.url?.absoluteString, "https://api.deepseek.com/chat/completions")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer secret-key")
        let body = try XCTUnwrap(request.httpBody)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
        XCTAssertEqual(json["model"] as? String, DeepSeekModel.flash.rawValue)
        XCTAssertEqual((json["response_format"] as? [String: String])?["type"], "json_object")
        let messages = try XCTUnwrap(json["messages"] as? [[String: String]])
        XCTAssertTrue(messages.map(\.content).joined().contains("sample-skill"))
        XCTAssertTrue(messages.map(\.content).joined().contains("Do not translate the Skill name"))
    }

    func testTranslateRejectsMalformedStructuredOutput() async throws {
        let responseData = try JSONSerialization.data(withJSONObject: [
            "choices": [["message": ["content": "not-json"]]]
        ])
        let provider = DeepSeekTranslationProvider(
            httpClient: StubTranslationHTTPClient(statusCode: 200, data: responseData)
        )

        do {
            _ = try await provider.translate(
                SkillTranslationRequest(skillName: "sample", description: "desc", markdown: "body"),
                apiKey: "secret",
                model: DeepSeekModel.flash.rawValue
            )
            XCTFail("Expected invalid response")
        } catch let error as TranslationProviderError {
            XCTAssertEqual(error, .invalidResponse)
        }
    }

    func testTranslateMapsUnauthorizedWithoutExposingCredential() async throws {
        let provider = DeepSeekTranslationProvider(
            httpClient: StubTranslationHTTPClient(statusCode: 401, data: Data("secret-key".utf8))
        )

        do {
            _ = try await provider.translate(
                SkillTranslationRequest(skillName: "sample", description: "desc", markdown: "body"),
                apiKey: "secret-key",
                model: DeepSeekModel.flash.rawValue
            )
            XCTFail("Expected invalid API key")
        } catch let error as TranslationProviderError {
            XCTAssertEqual(error, .invalidAPIKey)
            XCTAssertFalse(error.localizedDescription.contains("secret-key"))
        }
    }
}

private actor StubTranslationHTTPClient: TranslationHTTPClient {
    let statusCode: Int
    let data: Data
    private(set) var lastRequest: URLRequest?

    init(statusCode: Int, data: Data) {
        self.statusCode = statusCode
        self.data = data
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        lastRequest = request
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        return (data, response)
    }
}

private extension Dictionary where Key == String, Value == String {
    var content: String { self["content"] ?? "" }
}
