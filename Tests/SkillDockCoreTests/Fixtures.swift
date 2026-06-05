import Foundation

enum Fixtures {
    static func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: true
        )
        return url
    }

    static func write(_ contents: String, to url: URL) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try contents.write(to: url, atomically: true, encoding: .utf8)
    }

    static func makeSkill(
        at directory: URL,
        name: String? = "sample-skill",
        description: String? = "Sample description"
    ) throws {
        let frontmatter: String
        if let name, let description {
            frontmatter = """
            ---
            name: \(name)
            description: \(description)
            ---
            # Instructions
            """
        } else {
            frontmatter = "# Instructions"
        }
        try write(frontmatter, to: directory.appendingPathComponent("SKILL.md"))
    }
}
