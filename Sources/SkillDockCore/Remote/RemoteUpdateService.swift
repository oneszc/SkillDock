import Foundation

public actor RemoteUpdateService {
    private let repositoryService: RemoteRepositoryService
    private let hasher: SkillHasher
    private let fileManager: FileManager
    private let fileOperator: SkillFileOperator
    private let sourceStore: RemoteSourceStore

    public init(
        repositoryService: RemoteRepositoryService,
        hasher: SkillHasher = .init(),
        fileManager: FileManager = .default,
        fileOperator: SkillFileOperator = .init(),
        sourceStore: RemoteSourceStore = .init()
    ) {
        self.repositoryService = repositoryService
        self.hasher = hasher
        self.fileManager = fileManager
        self.fileOperator = fileOperator
        self.sourceStore = sourceStore
    }

    public func check(_ source: RemoteSkillSource) async throws -> RemoteSkillUpdate {
        let repository = try await repositoryService.acquire(
            GitHubRepositoryReference(
                owner: source.owner,
                repository: source.repository,
                branch: source.branch
            ),
            preference: source.requestedMethod
        )
        defer { cleanup(repository) }

        let remoteSkill = repository.localRoot
            .appendingPathComponent(source.repositoryRelativePath, isDirectory: true)
        let currentHash = try hasher.hash(directory: source.destination)
        let remoteHash = try hasher.hash(directory: remoteSkill)
        let status: RemoteUpdateStatus
        if currentHash == remoteHash {
            status = .upToDate
        } else if currentHash == source.installedContentHash {
            status = .updateAvailable
        } else {
            status = .localModified
        }
        let fileChanges = try fileChanges(current: source.destination, remote: remoteSkill)

        return RemoteSkillUpdate(
            source: source,
            status: status,
            currentContentHash: currentHash,
            remoteContentHash: remoteHash,
            currentCommit: source.commit,
            remoteCommit: repository.commit,
            addedFiles: fileChanges.added,
            modifiedFiles: fileChanges.modified,
            removedFiles: fileChanges.removed
        )
    }

    public func replaceWithRemote(
        _ update: RemoteSkillUpdate,
        libraryPath: URL
    ) async throws -> RemoteSkillReplacement {
        guard update.status == .updateAvailable else {
            throw RemoteUpdateError.localModifiedSkill
        }

        let repository = try await repositoryService.acquire(
            GitHubRepositoryReference(
                owner: update.source.owner,
                repository: update.source.repository,
                branch: update.source.branch
            ),
            preference: update.source.requestedMethod
        )
        defer { cleanup(repository) }

        let remoteSkill = repository.localRoot
            .appendingPathComponent(update.source.repositoryRelativePath, isDirectory: true)
        let result = try await fileOperator.copySkill(
            from: remoteSkill,
            to: libraryPath,
            strategy: .overwrite
        )
        let destination: URL
        switch result {
        case let .copied(url), let .skipped(url):
            destination = url
        }
        let updatedSource = RemoteSkillSource(
            destination: destination,
            skillName: update.source.skillName,
            repositoryURL: update.source.repositoryURL,
            owner: update.source.owner,
            repository: update.source.repository,
            branch: update.source.branch,
            repositoryRelativePath: update.source.repositoryRelativePath,
            requestedMethod: update.source.requestedMethod,
            actualMethod: repository.method,
            commit: repository.commit,
            installedContentHash: update.remoteContentHash,
            lastCheckedAt: Date()
        )
        try await sourceStore.upsert(updatedSource)
        return RemoteSkillReplacement(destination: destination, source: updatedSource)
    }

    private func fileChanges(
        current: URL,
        remote: URL
    ) throws -> (added: [String], modified: [String], removed: [String]) {
        let currentFiles = try relativeFiles(in: current)
        let remoteFiles = try relativeFiles(in: remote)
        let currentPaths = Set(currentFiles.keys)
        let remotePaths = Set(remoteFiles.keys)
        let added = remotePaths.subtracting(currentPaths).sorted()
        let removed = currentPaths.subtracting(remotePaths).sorted()
        let modified = try currentPaths.intersection(remotePaths)
            .filter { path in
                try Data(contentsOf: currentFiles[path]!) != Data(contentsOf: remoteFiles[path]!)
            }
            .sorted()

        return (added, modified, removed)
    }

    private func relativeFiles(in directory: URL) throws -> [String: URL] {
        guard let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: []
        ) else {
            return [:]
        }

        var files: [String: URL] = [:]
        for case let file as URL in enumerator {
            guard file.lastPathComponent != ".DS_Store" else { continue }
            let values = try file.resourceValues(forKeys: [.isRegularFileKey])
            guard values.isRegularFile == true else { continue }
            files[relativePath(for: file, in: directory)] = file
        }
        return files
    }

    private func relativePath(for file: URL, in directory: URL) -> String {
        let filePath = file.standardizedFileURL.path
        let directoryPath = directory.standardizedFileURL.path
        let path = String(filePath.dropFirst(directoryPath.count))
        return path.hasPrefix("/") ? String(path.dropFirst()) : path
    }

    private func cleanup(_ repository: RemoteRepository) {
        guard repository.requiresCleanup else { return }
        let operationDirectory = repository.localRoot
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        try? fileManager.removeItem(at: operationDirectory)
    }
}
