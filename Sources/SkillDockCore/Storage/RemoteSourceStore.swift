import Foundation

public actor RemoteSourceStore {
    private let store: JSONStore<[RemoteSkillSource]>

    public init(directory: URL = NotesStore.defaultDirectory) {
        store = JSONStore(
            fileURL: directory.appendingPathComponent("remote-sources.json"),
            defaultValue: []
        )
    }

    public func load() throws -> [RemoteSkillSource] {
        try store.load()
    }

    public func save(_ sources: [RemoteSkillSource]) throws {
        try store.save(sources)
    }

    public func upsert(_ source: RemoteSkillSource) throws {
        var sources = try load()
        let destinationPath = normalizedPath(source.destination)
        sources.removeAll { normalizedPath($0.destination) == destinationPath }
        sources.append(source)
        try save(sources)
    }

    public func remove(destination: URL) throws {
        var sources = try load()
        let destinationPath = normalizedPath(destination)
        sources.removeAll { normalizedPath($0.destination) == destinationPath }
        try save(sources)
    }

    public func source(for destination: URL) throws -> RemoteSkillSource? {
        let destinationPath = normalizedPath(destination)
        return try load().first { normalizedPath($0.destination) == destinationPath }
    }

    private func normalizedPath(_ url: URL) -> String {
        url.standardizedFileURL.path
    }
}
