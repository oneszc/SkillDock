import Foundation

public struct GitHubRepositoryMetadata: Equatable, Sendable {
    public let branch: String
    public let commit: String
    public let archiveURL: URL

    public init(branch: String, commit: String, archiveURL: URL) {
        self.branch = branch
        self.commit = commit
        self.archiveURL = archiveURL
    }
}

public enum GitHubZipRepositoryProviderError: Error, Sendable {
    case invalidResponse
    case invalidArchive
}

public actor GitHubZipRepositoryProvider: RemoteRepositoryProviding {
    public typealias MetadataResolver = @Sendable (GitHubRepositoryReference) async throws
        -> GitHubRepositoryMetadata
    public typealias ArchiveDownloader = @Sendable (URL) async throws -> Data

    private let temporaryDirectory: URL
    private let commandRunner: CommandRunner
    private let fileManager: FileManager
    private let metadataResolver: MetadataResolver
    private let archiveDownloader: ArchiveDownloader

    public init(
        temporaryDirectory: URL? = nil,
        commandRunner: CommandRunner = .init(),
        fileManager: FileManager = .default,
        metadataResolver: @escaping MetadataResolver = GitHubZipRepositoryProvider.resolveMetadata,
        archiveDownloader: @escaping ArchiveDownloader = GitHubZipRepositoryProvider.downloadArchive
    ) {
        self.temporaryDirectory = temporaryDirectory ?? fileManager.temporaryDirectory
        self.commandRunner = commandRunner
        self.fileManager = fileManager
        self.metadataResolver = metadataResolver
        self.archiveDownloader = archiveDownloader
    }

    public func acquire(_ reference: GitHubRepositoryReference) async throws -> RemoteRepository {
        let metadata = try await metadataResolver(reference)
        let archiveData = try await archiveDownloader(metadata.archiveURL)
        let operationDirectory = temporaryDirectory
            .appendingPathComponent("SkillDock-\(UUID().uuidString)", isDirectory: true)
        let archive = operationDirectory.appendingPathComponent("repository.zip")
        let extractionDirectory = operationDirectory.appendingPathComponent("extracted", isDirectory: true)

        try fileManager.createDirectory(at: extractionDirectory, withIntermediateDirectories: true)
        try archiveData.write(to: archive, options: .atomic)
        _ = try await commandRunner.run(
            executable: URL(fileURLWithPath: "/usr/bin/ditto"),
            arguments: ["-x", "-k", archive.path, extractionDirectory.path]
        )

        let contents = try fileManager.contentsOfDirectory(
            at: extractionDirectory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )
        guard contents.count == 1,
              (try contents[0].resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true else {
            try? fileManager.removeItem(at: operationDirectory)
            throw GitHubZipRepositoryProviderError.invalidArchive
        }

        let resolvedReference = GitHubRepositoryReference(
            owner: reference.owner,
            repository: reference.repository,
            branch: metadata.branch,
            folderPath: reference.folderPath
        )
        return RemoteRepository(
            reference: resolvedReference,
            localRoot: contents[0],
            method: .zip,
            commit: metadata.commit,
            requiresCleanup: true
        )
    }

    public static func resolveMetadata(
        for reference: GitHubRepositoryReference
    ) async throws -> GitHubRepositoryMetadata {
        let repositoryURL = URL(
            string: "https://api.github.com/repos/\(reference.owner)/\(reference.repository)"
        )!
        let repositoryData = try await requestData(from: repositoryURL)
        let repository = try JSONDecoder().decode(RepositoryResponse.self, from: repositoryData)
        let branch = reference.branch ?? repository.defaultBranch
        guard let encodedBranch = branch.addingPercentEncoding(
            withAllowedCharacters: .urlPathAllowed
        ) else {
            throw GitHubZipRepositoryProviderError.invalidResponse
        }
        let commitURL = URL(
            string: "https://api.github.com/repos/\(reference.owner)/\(reference.repository)/commits/\(encodedBranch)"
        )!
        let commitData = try await requestData(from: commitURL)
        let commit = try JSONDecoder().decode(CommitResponse.self, from: commitData)
        let archiveURL = URL(
            string: "https://github.com/\(reference.owner)/\(reference.repository)/archive/\(commit.sha).zip"
        )!
        return GitHubRepositoryMetadata(branch: branch, commit: commit.sha, archiveURL: archiveURL)
    }

    public static func downloadArchive(from url: URL) async throws -> Data {
        try await requestData(from: url)
    }

    private static func requestData(from url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue("SkillDock", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse,
              (200..<300).contains(response.statusCode) else {
            throw GitHubZipRepositoryProviderError.invalidResponse
        }
        return data
    }
}

private struct RepositoryResponse: Decodable {
    let defaultBranch: String

    enum CodingKeys: String, CodingKey {
        case defaultBranch = "default_branch"
    }
}

private struct CommitResponse: Decodable {
    let sha: String
}
