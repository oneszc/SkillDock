import Foundation

public struct CodexPluginSkillSourceResolution: Sendable {
    public let locations: [ScanLocation]
    public let issues: [SkillScanIssue]

    public init(locations: [ScanLocation], issues: [SkillScanIssue]) {
        self.locations = locations
        self.issues = issues
    }
}

public struct CodexPluginSkillSourceResolver: @unchecked Sendable {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func resolve(homeDirectory: URL) -> CodexPluginSkillSourceResolution {
        let cacheRoot = homeDirectory.appendingPathComponent(".codex/plugins/cache", isDirectory: true)
        guard fileManager.fileExists(atPath: cacheRoot.path) else {
            return CodexPluginSkillSourceResolution(locations: [], issues: [])
        }

        var locations: [ScanLocation] = []
        var issues: [SkillScanIssue] = []

        for pluginRoot in pluginRoots(in: cacheRoot) {
            let versionRoots = childDirectories(in: pluginRoot).filter {
                fileManager.fileExists(
                    atPath: $0.appendingPathComponent(".codex-plugin/plugin.json").path
                )
            }

            guard versionRoots.count <= 1 else {
                issues.append(
                    SkillScanIssue(
                        root: pluginRoot,
                        source: .available(.plugin),
                        message: "Multiple plugin versions found at \(pluginRoot.path). SkillDock skipped this Plugin source until the active version can be determined."
                    )
                )
                continue
            }

            guard let versionRoot = versionRoots.first else { continue }
            let manifestURL = versionRoot.appendingPathComponent(".codex-plugin/plugin.json")
            do {
                let manifest = try PluginManifest.load(from: manifestURL)
                guard let skillsPath = manifest.skills?.trimmingCharacters(in: .whitespacesAndNewlines),
                      !skillsPath.isEmpty else {
                    continue
                }
                let skillsRoot = versionRoot.appendingPathComponent(skillsPath, isDirectory: true)
                    .resolvingSymlinksInPath()
                    .standardizedFileURL
                let versionRootPath = versionRoot
                    .resolvingSymlinksInPath()
                    .standardizedFileURL
                    .path
                guard skillsRoot.path == versionRootPath ||
                      skillsRoot.path.hasPrefix(versionRootPath + "/"),
                      fileManager.fileExists(atPath: skillsRoot.path) else {
                    continue
                }
                locations.append(ScanLocation(root: skillsRoot, source: .available(.plugin)))
            } catch {
                issues.append(
                    SkillScanIssue(
                        root: manifestURL,
                        source: .available(.plugin),
                        message: "Could not read Plugin manifest at \(manifestURL.path): \(error.localizedDescription)"
                    )
                )
            }
        }

        return CodexPluginSkillSourceResolution(
            locations: locations.sorted { $0.root.path < $1.root.path },
            issues: issues
        )
    }

    private func pluginRoots(in cacheRoot: URL) -> [URL] {
        childDirectories(in: cacheRoot).flatMap { provider in
            childDirectories(in: provider)
        }
    }

    private func childDirectories(in root: URL) -> [URL] {
        guard let children = try? fileManager.contentsOfDirectory(
            at: root,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        return children.filter {
            (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
        }
    }
}

private struct PluginManifest: Decodable {
    let skills: String?

    static func load(from url: URL) throws -> PluginManifest {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(PluginManifest.self, from: data)
    }
}
