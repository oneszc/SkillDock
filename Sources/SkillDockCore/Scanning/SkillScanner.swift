import Foundation

public struct ScanLocation: Sendable {
    public let root: URL
    public let source: SkillSource

    public init(root: URL, source: SkillSource) {
        self.root = root
        self.source = source
    }
}

public actor SkillScanner {
    private let parser: SkillMarkdownParser
    private let hasher: SkillHasher
    private let fileManager: FileManager

    public init(
        parser: SkillMarkdownParser = .init(),
        hasher: SkillHasher = .init(),
        fileManager: FileManager = .default
    ) {
        self.parser = parser
        self.hasher = hasher
        self.fileManager = fileManager
    }

    public func scan(_ locations: [ScanLocation]) async -> [Skill] {
        locations
            .flatMap(scan)
            .sorted {
                if $0.name == $1.name {
                    return $0.path.path < $1.path.path
                }
                return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
    }

    private func scan(_ location: ScanLocation) -> [Skill] {
        directories(including: location.root).compactMap { directory in
            makeSkill(at: directory, source: location.source)
        }
    }

    private func directories(including root: URL) -> [URL] {
        guard fileManager.fileExists(atPath: root.path) else { return [] }

        var result = [root]
        guard let enumerator = fileManager.enumerator(
            at: root,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: []
        ) else {
            return result
        }

        for case let url as URL in enumerator {
            if (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                result.append(url)
            }
        }
        return result
    }

    private func makeSkill(at directory: URL, source: SkillSource) -> Skill? {
        let skillFile = directory.appendingPathComponent("SKILL.md")
        guard fileManager.fileExists(atPath: skillFile.path),
              let markdown = try? String(contentsOf: skillFile, encoding: .utf8),
              let metadata = try? parser.parse(markdown),
              let contentHash = try? hasher.hash(directory: directory)
        else {
            return nil
        }

        let name = metadata.name ?? directory.lastPathComponent
        let isSystem = source == .codex && directory.pathComponents.contains(".system")
        var scriptsIsDirectory = ObjCBool(false)
        let hasScripts = fileManager.fileExists(
            atPath: directory.appendingPathComponent("scripts", isDirectory: true).path,
            isDirectory: &scriptsIsDirectory
        ) && scriptsIsDirectory.boolValue

        return Skill(
            id: "\(source.rawValue):\(name.lowercased()):\(contentHash)",
            name: name,
            description: metadata.description,
            path: directory,
            source: source,
            hasScripts: hasScripts,
            isSystem: isSystem,
            isReadOnly: isSystem,
            contentHash: contentHash,
            installation: SkillInstallation(
                codex: source == .codex,
                claude: source == .claude
            )
        )
    }
}
