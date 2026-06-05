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

    static func snapshot(directory: URL) throws -> [String: Data] {
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: []
        ) else {
            return [:]
        }

        var snapshot: [String: Data] = [:]
        for case let file as URL in enumerator {
            guard (try? file.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true else {
                continue
            }
            let relativePath = String(file.path.dropFirst(directory.path.count))
            snapshot[relativePath] = try Data(contentsOf: file)
        }
        return snapshot
    }
}
