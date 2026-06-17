import CryptoKit
import Foundation

public struct SkillHasher: Sendable {
    public init() {}

    public func hash(directory: URL) throws -> String {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: []
        ) else {
            return SHA256.hash(data: Data()).hexString
        }

        let files = enumerator.compactMap { item -> URL? in
            guard let url = item as? URL else { return nil }
            if url.lastPathComponent == ".git" {
                enumerator.skipDescendants()
                return nil
            }
            return url
        }
            .filter { url in
                guard url.lastPathComponent != ".DS_Store" else { return false }
                guard !url.pathComponents.contains(".git") else { return false }
                return (try? url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true
            }
            .sorted { relativePath(for: $0, in: directory) < relativePath(for: $1, in: directory) }

        var hasher = SHA256()
        for file in files {
            hasher.update(data: Data(relativePath(for: file, in: directory).utf8))
            hasher.update(data: try Data(contentsOf: file))
        }

        return hasher.finalize().hexString
    }

    private func relativePath(for file: URL, in directory: URL) -> String {
        String(file.path.dropFirst(directory.path.count))
    }
}

private extension Digest {
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
