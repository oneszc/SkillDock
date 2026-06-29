import Foundation

public struct RemoteRepositoryPluginDetector {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func detect(in root: URL) -> Set<RemotePluginManifestKind> {
        var kinds = Set<RemotePluginManifestKind>()
        if fileManager.fileExists(atPath: root.appendingPathComponent(".codex-plugin/plugin.json").path) {
            kinds.insert(.codex)
        }
        if fileManager.fileExists(atPath: root.appendingPathComponent(".claude-plugin/plugin.json").path) {
            kinds.insert(.claude)
        }
        return kinds
    }
}
