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

    static func makeSkillWithFiles(
        at directory: URL,
        name: String = "sample-skill"
    ) throws {
        try makeSkill(at: directory, name: name)
        try write(
            "print('hello')",
            to: directory.appendingPathComponent("scripts/run.py")
        )
        try write(
            "# Reference",
            to: directory.appendingPathComponent("references/guide.md")
        )
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

    static func makeGitRemoteWithSkill() throws -> (remote: URL, commit: String) {
        let root = try temporaryDirectory()
        let remote = root.appendingPathComponent("remote.git", isDirectory: true)
        let working = root.appendingPathComponent("working", isDirectory: true)

        try run("/usr/bin/git", ["init", "--bare", remote.path])
        try run("/usr/bin/git", ["init", working.path])
        try run("/usr/bin/git", ["-C", working.path, "config", "user.name", "SkillDock Tests"])
        try run("/usr/bin/git", ["-C", working.path, "config", "user.email", "tests@skilldock.local"])
        try makeSkill(at: working.appendingPathComponent("skills/example"))
        try run("/usr/bin/git", ["-C", working.path, "add", "."])
        try run("/usr/bin/git", ["-C", working.path, "commit", "-m", "Add example skill"])
        try run("/usr/bin/git", ["-C", working.path, "branch", "-M", "main"])
        try run("/usr/bin/git", ["-C", working.path, "remote", "add", "origin", remote.path])
        try run("/usr/bin/git", ["-C", working.path, "push", "-u", "origin", "main"])
        let commit = try run("/usr/bin/git", ["-C", working.path, "rev-parse", "HEAD"])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (remote, commit)
    }

    @discardableResult
    static func run(_ executable: String, _ arguments: [String]) throws -> String {
        let process = Process()
        let output = Pipe()
        let error = Pipe()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = output
        process.standardError = error
        try process.run()
        process.waitUntilExit()
        let standardOutput = String(
            data: output.fileHandleForReading.readDataToEndOfFile(),
            encoding: .utf8
        ) ?? ""
        guard process.terminationStatus == 0 else {
            let standardError = String(
                data: error.fileHandleForReading.readDataToEndOfFile(),
                encoding: .utf8
            ) ?? ""
            throw NSError(
                domain: "Fixtures.Command",
                code: Int(process.terminationStatus),
                userInfo: [NSLocalizedDescriptionKey: standardError]
            )
        }
        return standardOutput
    }
}
