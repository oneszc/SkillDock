import Foundation

public enum GitHubURLParserError: Error, Equatable, Sendable {
    case invalidURL
    case unsupportedHost
    case missingRepository
}

public struct GitHubURLParser: Sendable {
    public init() {}

    public func parse(_ value: String) throws -> GitHubRepositoryReference {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let components = URLComponents(string: trimmed),
              components.scheme == "https",
              let host = components.host
        else {
            throw GitHubURLParserError.invalidURL
        }
        guard host.lowercased() == "github.com" || host.lowercased() == "www.github.com" else {
            throw GitHubURLParserError.unsupportedHost
        }

        let pathComponents = components.path
            .split(separator: "/", omittingEmptySubsequences: true)
            .map(String.init)
        guard pathComponents.count >= 2 else {
            throw GitHubURLParserError.missingRepository
        }

        let owner = pathComponents[0]
        let repository = pathComponents[1].replacingOccurrences(
            of: #"\.git$"#,
            with: "",
            options: .regularExpression
        )
        guard !owner.isEmpty, !repository.isEmpty else {
            throw GitHubURLParserError.missingRepository
        }

        if pathComponents.count >= 4, pathComponents[2] == "tree" {
            let folderPath = pathComponents.dropFirst(4).joined(separator: "/")
            return GitHubRepositoryReference(
                owner: owner,
                repository: repository,
                branch: pathComponents[3],
                folderPath: folderPath.isEmpty ? nil : folderPath
            )
        }

        return GitHubRepositoryReference(owner: owner, repository: repository)
    }
}
