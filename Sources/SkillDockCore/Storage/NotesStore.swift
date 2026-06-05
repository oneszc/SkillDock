import Foundation

public actor NotesStore {
    private let store: JSONStore<[SkillNote]>

    public init(directory: URL = NotesStore.defaultDirectory) {
        store = JSONStore(
            fileURL: directory.appendingPathComponent("notes.json"),
            defaultValue: []
        )
    }

    public func load() throws -> [SkillNote] {
        try store.load()
    }

    public func save(_ notes: [SkillNote]) throws {
        try store.save(notes)
    }

    public func upsert(_ note: SkillNote) throws {
        var notes = try load()
        var normalizedNote = note
        normalizedNote.tags = normalize(note.tags)
        normalizedNote.useCases = normalize(note.useCases)
        notes.removeAll { $0.key == normalizedNote.key }
        notes.append(normalizedNote)
        try save(notes)
    }

    public func suggestions() throws -> NoteSuggestions {
        let notes = try load()
        return NoteSuggestions(
            tags: normalize(notes.flatMap(\.tags)).sorted {
                $0.localizedStandardCompare($1) == .orderedAscending
            },
            useCases: normalize(notes.flatMap(\.useCases)).sorted {
                $0.localizedStandardCompare($1) == .orderedAscending
            }
        )
    }

    public func match(
        name: String,
        source: SkillSource,
        contentHash: String
    ) throws -> SkillNoteMatch? {
        let notes = try load().filter {
            $0.key.name == name && $0.key.source == source
        }
        if let exact = notes.first(where: { $0.key.contentHash == contentHash }) {
            return SkillNoteMatch(note: exact, isStale: false)
        }
        guard let latest = notes.max(by: { $0.updatedAt < $1.updatedAt }) else {
            return nil
        }
        return SkillNoteMatch(note: latest, isStale: true)
    }

    public static var defaultDirectory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SkillDock", isDirectory: true)
    }

    private func normalize(_ values: [String]) -> [String] {
        var seen: Set<String> = []
        return values.compactMap {
            let value = $0.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !value.isEmpty else { return nil }
            let key = value.folding(
                options: [.caseInsensitive, .diacriticInsensitive],
                locale: .current
            )
            guard seen.insert(key).inserted else { return nil }
            return value
        }
    }
}
