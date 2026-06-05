import Foundation

public actor ImportPreviewService {
    private let parser: SkillMarkdownParser
    private let workspace: SkillWorkspaceService
    private let fileManager: FileManager

    public init(
        parser: SkillMarkdownParser = .init(),
        workspace: SkillWorkspaceService = .init(),
        fileManager: FileManager = .default
    ) {
        self.parser = parser
        self.workspace = workspace
        self.fileManager = fileManager
    }

    public func preview(urls: [URL], libraryPath: URL) async throws -> ImportPreview {
        guard urls.count == 1 else {
            throw ImportPreviewError.requiresSingleFolder
        }

        let source = urls[0]
        guard (try? source.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true else {
            throw ImportPreviewError.requiresSingleFolder
        }

        let markdownURL = source.appendingPathComponent("SKILL.md")
        guard fileManager.fileExists(atPath: markdownURL.path) else {
            throw ImportPreviewError.missingSkillMarkdown
        }

        let markdown = try String(contentsOf: markdownURL, encoding: .utf8)
        let metadata = try parser.parse(markdown)
        let paths = try await workspace.fileTree(for: source)
        let fileCount = paths.filter { relativePath in
            let item = source.appendingPathComponent(relativePath)
            return (try? item.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true
        }.count
        let destination = libraryPath.appendingPathComponent(source.lastPathComponent)

        return ImportPreview(
            sourceURL: source,
            name: metadata.name ?? source.lastPathComponent,
            description: metadata.description,
            relativePaths: paths,
            fileCount: fileCount,
            hasScripts: paths.contains("scripts"),
            hasConflict: fileManager.fileExists(atPath: destination.path)
        )
    }
}
