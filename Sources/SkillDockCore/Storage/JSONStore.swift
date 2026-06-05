import Foundation

struct JSONStore<Value: Codable> {
    let fileURL: URL
    let defaultValue: Value

    func load() throws -> Value {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return defaultValue
        }
        return try JSONDecoder.skillDock.decode(Value.self, from: Data(contentsOf: fileURL))
    }

    func save(_ value: Value) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try JSONEncoder.skillDock.encode(value).write(to: fileURL, options: .atomic)
    }
}

private extension JSONEncoder {
    static var skillDock: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

private extension JSONDecoder {
    static var skillDock: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
