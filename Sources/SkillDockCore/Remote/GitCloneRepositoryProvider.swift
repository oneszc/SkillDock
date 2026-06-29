import Foundation

public actor GitCloneRepositoryProvider: RemoteRepositoryProviding {
    private let repositoriesDirectory: URL
    private let commandRunner: CommandRunner
    private let fileManager: FileManager
    private let pluginDetector: RemoteRepositoryPluginDetector

    public init(
        repositoriesDirectory: URL? = nil,
        commandRunner: CommandRunner = .init(),
        fileManager: FileManager = .default,
        pluginDetector: RemoteRepositoryPluginDetector = .init()
    ) {
        self.repositoriesDirectory = repositoriesDirectory
            ?? Self.defaultRepositoriesDirectory(fileManager: fileManager)
        self.commandRunner = commandRunner
        self.fileManager = fileManager
        self.pluginDetector = pluginDetector
    }

    public func acquire(
        _ reference: GitHubRepositoryReference
    ) async throws -> RemoteRepository {
        try await acquire(reference, cloneURL: nil)
    }

    public func acquire(
        _ reference: GitHubRepositoryReference,
        cloneURL: URL?
    ) async throws -> RemoteRepository {
        try fileManager.createDirectory(
            at: repositoriesDirectory,
            withIntermediateDirectories: true
        )
        let localRoot = repositoriesDirectory.appendingPathComponent(
            "\(reference.owner)--\(reference.repository)",
            isDirectory: true
        )

        if fileManager.fileExists(atPath: localRoot.appendingPathComponent(".git").path) {
            try await refresh(reference, at: localRoot)
        } else {
            if fileManager.fileExists(atPath: localRoot.path) {
                try fileManager.removeItem(at: localRoot)
            }
            var arguments = ["clone", "--quiet"]
            if let branch = reference.branch {
                arguments += ["--branch", branch]
            }
            arguments += [(cloneURL ?? reference.cloneURL).absoluteString, localRoot.path]
            _ = try await commandRunner.run(
                executable: URL(fileURLWithPath: "/usr/bin/git"),
                arguments: arguments
            )
        }

        let commit = try await commandRunner.run(
            executable: URL(fileURLWithPath: "/usr/bin/git"),
            arguments: ["-C", localRoot.path, "rev-parse", "HEAD"]
        ).standardOutput.trimmingCharacters(in: .whitespacesAndNewlines)

        return RemoteRepository(
            reference: reference,
            localRoot: localRoot,
            method: .gitClone,
            commit: commit,
            requiresCleanup: false,
            pluginManifestKinds: pluginDetector.detect(in: localRoot)
        )
    }

    private func refresh(
        _ reference: GitHubRepositoryReference,
        at localRoot: URL
    ) async throws {
        _ = try await commandRunner.run(
            executable: URL(fileURLWithPath: "/usr/bin/git"),
            arguments: ["-C", localRoot.path, "fetch", "--quiet", "origin"]
        )
        let target = reference.branch.map { "origin/\($0)" } ?? "origin/HEAD"
        _ = try await commandRunner.run(
            executable: URL(fileURLWithPath: "/usr/bin/git"),
            arguments: ["-C", localRoot.path, "reset", "--hard", "--quiet", target]
        )
    }

    private static func defaultRepositoriesDirectory(fileManager: FileManager) -> URL {
        let applicationSupport = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? fileManager.homeDirectoryForCurrentUser
        return applicationSupport
            .appendingPathComponent("SkillDock", isDirectory: true)
            .appendingPathComponent("Repositories", isDirectory: true)
    }
}
