import Foundation

public struct ScanLocation: Sendable {
    public let root: URL
    public let source: SkillSource
    public let excludedRoots: Set<URL>

    public init(
        root: URL,
        source: SkillSource,
        excludedRoots: Set<URL> = []
    ) {
        self.root = root
        self.source = source
        self.excludedRoots = excludedRoots
    }
}

public struct SkillScanIssue: Equatable, Sendable {
    public let root: URL
    public let source: SkillSource
    public let message: String

    public init(root: URL, source: SkillSource, message: String) {
        self.root = root
        self.source = source
        self.message = message
    }
}

public struct SkillScanResult: Equatable, Sendable {
    public let skills: [Skill]
    public let issues: [SkillScanIssue]

    public init(skills: [Skill], issues: [SkillScanIssue]) {
        self.skills = skills
        self.issues = issues
    }
}

public actor SkillScanner {
    private let parser: SkillMarkdownParser
    private let hasher: SkillHasher
    private let fileManager: FileManager
    private let enumeratorProvider: (
        URL,
        [URLResourceKey]?,
        ((URL, any Error) -> Bool)?
    ) -> FileManager.DirectoryEnumerator?

    public init(
        parser: SkillMarkdownParser = .init(),
        hasher: SkillHasher = .init(),
        fileManager: FileManager = .default
    ) {
        self.parser = parser
        self.hasher = hasher
        self.fileManager = fileManager
        self.enumeratorProvider = { url, keys, errorHandler in
            fileManager.enumerator(
                at: url,
                includingPropertiesForKeys: keys,
                options: [],
                errorHandler: errorHandler
            )
        }
    }

    init(
        parser: SkillMarkdownParser = .init(),
        hasher: SkillHasher = .init(),
        fileManager: FileManager = .default,
        enumeratorProvider: @escaping (
            URL,
            [URLResourceKey]?,
            ((URL, any Error) -> Bool)?
        ) -> FileManager.DirectoryEnumerator?
    ) {
        self.parser = parser
        self.hasher = hasher
        self.fileManager = fileManager
        self.enumeratorProvider = enumeratorProvider
    }

    public func scan(_ locations: [ScanLocation]) async -> SkillScanResult {
        var skills: [Skill] = []
        var issues: [SkillScanIssue] = []
        for location in locations {
            let locationResult = scan(location)
            skills += locationResult.skills
            issues += locationResult.issues
        }
        return SkillScanResult(
            skills: skills.sorted {
                if $0.name == $1.name {
                    return $0.path.path < $1.path.path
                }
                return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            },
            issues: issues
        )
    }

    private func scan(_ location: ScanLocation) -> SkillScanResult {
        let directories = directories(in: location)
        return SkillScanResult(
            skills: directories.values.compactMap { directory in
                makeSkill(at: directory, source: location.source)
            },
            issues: directories.issue.map { [$0] } ?? []
        )
    }

    private func directories(
        in location: ScanLocation
    ) -> (values: [URL], issue: SkillScanIssue?) {
        let root = location.root
        guard fileManager.fileExists(atPath: root.path) else { return ([], nil) }

        var result = [root]
        let excludedRoots = Set(location.excludedRoots.map(scanComparisonIdentity))
        var traversalErrorMessage: String?
        let errorHandler: (URL, any Error) -> Bool = { _, error in
            if traversalErrorMessage == nil {
                traversalErrorMessage = error.localizedDescription
            }
            return true
        }
        guard let enumerator = enumeratorProvider(
            root,
            [.isDirectoryKey],
            errorHandler
        ) else {
            return (
                [],
                SkillScanIssue(
                    root: root,
                    source: location.source,
                    message: "Could not read \(location.source.displayName) skills at \(root.path)."
                )
            )
        }

        for case let url as URL in enumerator {
            let candidate = scanComparisonIdentity(url)
            if excludedRoots.contains(candidate) {
                enumerator.skipDescendants()
                continue
            }
            if (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                result.append(url)
            }
        }
        let issue = traversalErrorMessage.map { message in
            SkillScanIssue(
                root: root,
                source: location.source,
                message: "Could not completely read \(location.source.displayName) skills at \(root.path): \(message)"
            )
        }
        return (result, issue)
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
        let availableSource: AvailableSkillSource?
        if case .available(let value) = source {
            availableSource = value
        } else {
            availableSource = nil
        }
        let isSystem = availableSource == .system
        let isReadOnly = availableSource != nil
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
            isReadOnly: isReadOnly,
            contentHash: contentHash,
            installation: installation(for: source)
        )
    }

    private func installation(for source: SkillSource) -> SkillInstallation {
        switch source {
        case .library:
            .init()
        case .agent(let id):
            .init(agentIDs: [id])
        case .available:
            .init()
        }
    }

}

func scanComparisonIdentity(_ url: URL) -> URL {
    url.resolvingSymlinksInPath().standardizedFileURL
}
