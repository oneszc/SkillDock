import Foundation

public struct MarkdownPreviewDocument: Equatable, Sendable {
    public enum Block: Equatable, Sendable {
        case heading(level: Int, text: String)
        case paragraph(String)
        case unorderedList([String])
        case orderedList([String])
        case quote(String)
        case code(language: String?, text: String)
        case divider
    }

    public let blocks: [Block]

    public init(markdown: String) {
        blocks = Self.parse(Self.removingFrontmatter(from: markdown))
    }

    private static func removingFrontmatter(from markdown: String) -> [String] {
        var lines = markdown.components(separatedBy: .newlines)
        guard lines.first?.trimmingCharacters(in: .whitespaces) == "---" else {
            return lines
        }
        lines.removeFirst()
        while !lines.isEmpty {
            let line = lines.removeFirst()
            if line.trimmingCharacters(in: .whitespaces) == "---" {
                break
            }
        }
        return lines
    }

    private static func parse(_ lines: [String]) -> [Block] {
        var blocks: [Block] = []
        var index = 0

        while index < lines.count {
            let line = lines[index]
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                index += 1
                continue
            }

            if trimmed.hasPrefix("```") {
                let language = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                index += 1
                var codeLines: [String] = []
                while index < lines.count && !lines[index].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                    codeLines.append(lines[index])
                    index += 1
                }
                if index < lines.count {
                    index += 1
                }
                blocks.append(.code(language: language.isEmpty ? nil : language, text: codeLines.joined(separator: "\n")))
                continue
            }

            if let heading = heading(from: trimmed) {
                blocks.append(heading)
                index += 1
                continue
            }

            if isDivider(trimmed) {
                blocks.append(.divider)
                index += 1
                continue
            }

            if unorderedItem(from: trimmed) != nil {
                var items: [String] = []
                while index < lines.count, let item = unorderedItem(
                    from: lines[index].trimmingCharacters(in: .whitespaces)
                ) {
                    items.append(item)
                    index += 1
                }
                blocks.append(.unorderedList(items))
                continue
            }

            if orderedItem(from: trimmed) != nil {
                var items: [String] = []
                while index < lines.count, let item = orderedItem(
                    from: lines[index].trimmingCharacters(in: .whitespaces)
                ) {
                    items.append(item)
                    index += 1
                }
                blocks.append(.orderedList(items))
                continue
            }

            if trimmed.hasPrefix(">") {
                var quoteLines: [String] = []
                while index < lines.count {
                    let quote = lines[index].trimmingCharacters(in: .whitespaces)
                    guard quote.hasPrefix(">") else { break }
                    quoteLines.append(String(quote.dropFirst()).trimmingCharacters(in: .whitespaces))
                    index += 1
                }
                blocks.append(.quote(quoteLines.joined(separator: " ")))
                continue
            }

            var paragraphLines: [String] = []
            while index < lines.count {
                let candidate = lines[index].trimmingCharacters(in: .whitespaces)
                guard !candidate.isEmpty && !startsBlock(candidate) else { break }
                paragraphLines.append(candidate)
                index += 1
            }
            blocks.append(.paragraph(paragraphLines.joined(separator: " ")))
        }

        return blocks
    }

    private static func heading(from line: String) -> Block? {
        let hashes = line.prefix { $0 == "#" }
        guard (1...6).contains(hashes.count) else { return nil }
        let text = line.dropFirst(hashes.count).trimmingCharacters(in: .whitespaces)
        return text.isEmpty ? nil : .heading(level: hashes.count, text: text)
    }

    private static func unorderedItem(from line: String) -> String? {
        for prefix in ["- ", "* ", "+ "] where line.hasPrefix(prefix) {
            return String(line.dropFirst(prefix.count))
        }
        return nil
    }

    private static func orderedItem(from line: String) -> String? {
        guard let separator = line.firstIndex(of: "."),
              separator != line.startIndex,
              line.index(after: separator) < line.endIndex,
              line[line.index(after: separator)] == " ",
              line[..<separator].allSatisfy(\.isNumber) else {
            return nil
        }
        return String(line[line.index(separator, offsetBy: 2)...])
    }

    private static func isDivider(_ line: String) -> Bool {
        ["---", "***", "___"].contains(line)
    }

    private static func startsBlock(_ line: String) -> Bool {
        line.hasPrefix("```")
            || heading(from: line) != nil
            || isDivider(line)
            || unorderedItem(from: line) != nil
            || orderedItem(from: line) != nil
            || line.hasPrefix(">")
    }
}
