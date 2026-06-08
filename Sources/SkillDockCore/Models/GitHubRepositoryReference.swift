import Foundation

public struct GitHubRepositoryReference: Equatable, Sendable {
    public let owner: String
    public let repository: String
    public let branch: String?
    public let folderPath: String?

    public init(
        owner: String,
        repository: String,
        branch: String? = nil,
        folderPath: String? = nil
    ) {
        self.owner = owner
        self.repository = repository
        self.branch = branch
        self.folderPath = folderPath
    }

    public var repositoryURL: URL {
        URL(string: "https://github.com/\(owner)/\(repository)")!
    }

    public var cloneURL: URL {
        URL(string: "https://github.com/\(owner)/\(repository).git")!
    }
}
