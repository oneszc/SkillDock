import Foundation

public actor RemoteSkillScanner {
    private let parser: SkillMarkdownParser
    private let hasher: SkillHasher
    private let workspace: SkillWorkspaceService
    private let fileManager: FileManager

    public init(
        parser: SkillMarkdownParser = .init(),
        hasher: SkillHasher = .init(),
        workspace: SkillWorkspaceService = .init(),
        fileManager: FileManager = .default
    ) {
        self.parser = parser
        self.hasher = hasher
        self.workspace = workspace
        self.fileManager = fileManager
    }

    public func scan(
        repository: RemoteRepository,
        libraryPath: URL
    ) async throws -> [RemoteSkillCandidate] {
        var candidates: [RemoteSkillCandidate] = []
        for directory in try skillDirectories(in: repository.localRoot) {
            candidates.append(
                try await candidate(
                    at: directory,
                    repository: repository,
                    libraryPath: libraryPath
                )
            )
        }
        return candidates.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    private func skillDirectories(in root: URL) throws -> [URL] {
        var result: [URL] = []
        if fileManager.fileExists(atPath: root.appendingPathComponent("SKILL.md").path) {
            result.append(root)
        }
        guard let enumerator = fileManager.enumerator(
            at: root,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return result
        }
        for case let directory as URL in enumerator where
            (try? directory.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
            && fileManager.fileExists(atPath: directory.appendingPathComponent("SKILL.md").path)
        {
            result.append(directory)
        }
        return result
    }

    private func candidate(
        at directory: URL,
        repository: RemoteRepository,
        libraryPath: URL
    ) async throws -> RemoteSkillCandidate {
        let markdown = try String(
            contentsOf: directory.appendingPathComponent("SKILL.md"),
            encoding: .utf8
        )
        let metadata = try parser.parse(markdown)
        let paths = try await workspace.fileTree(for: directory)
        let relativePath = String(
            directory.standardizedFileURL.path
                .dropFirst(repository.localRoot.standardizedFileURL.path.count)
        ).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let destination = libraryPath.appendingPathComponent(directory.lastPathComponent)

        return RemoteSkillCandidate(
            sourceURL: directory,
            repositoryRelativePath: relativePath,
            name: metadata.name ?? directory.lastPathComponent,
            description: metadata.description,
            contentHash: try hasher.hash(directory: directory),
            relativePaths: paths,
            fileCount: paths.filter {
                let item = directory.appendingPathComponent($0)
                return (try? item.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true
            }.count,
            hasScripts: paths.contains("scripts"),
            hasConflict: fileManager.fileExists(atPath: destination.path),
            isSelected: repository.reference.folderPath == relativePath
        )
    }
}
