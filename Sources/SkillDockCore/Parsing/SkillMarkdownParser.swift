import Foundation

public struct SkillMarkdownParser: Sendable {
    public init() {}

    public func parse(_ markdown: String) throws -> SkillMetadata {
        let lines = markdown.components(separatedBy: .newlines)
        guard lines.first?.trimmingCharacters(in: .whitespaces) == "---" else {
            return SkillMetadata(name: nil, description: nil)
        }

        var name: String?
        var description: String?

        for line in lines.dropFirst() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed == "---" {
                break
            }

            if trimmed.hasPrefix("name:") {
                name = value(after: "name:", in: trimmed)
            } else if trimmed.hasPrefix("description:") {
                description = value(after: "description:", in: trimmed)
            }
        }

        return SkillMetadata(name: name, description: description)
    }

    private func value(after prefix: String, in line: String) -> String? {
        let value = line.dropFirst(prefix.count).trimmingCharacters(in: .whitespaces)
        return value.isEmpty ? nil : value
    }
}
