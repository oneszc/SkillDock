import Foundation

public actor TranslationStore {
    private let store: JSONStore<[SkillTranslation]>

    public init(directory: URL = NotesStore.defaultDirectory) {
        store = JSONStore(
            fileURL: directory.appendingPathComponent("translations.json"),
            defaultValue: []
        )
    }

    public func load() throws -> [SkillTranslation] {
        try store.load()
    }

    public func save(_ translations: [SkillTranslation]) throws {
        try store.save(translations)
    }

    public func upsert(_ translation: SkillTranslation) throws {
        var translations = try load()
        translations.removeAll {
            $0.skillName == translation.skillName && $0.source == translation.source
        }
        translations.append(translation)
        try save(translations)
    }

    public func match(
        name: String,
        source: SkillSource,
        contentHash: String
    ) throws -> SkillTranslationMatch? {
        let translations = try load().filter {
            $0.skillName == name && $0.source == source
        }
        if let exact = translations.first(where: { $0.contentHash == contentHash }) {
            return SkillTranslationMatch(translation: exact, isStale: false)
        }
        guard let latest = translations.max(by: { $0.generatedAt < $1.generatedAt }) else {
            return nil
        }
        return SkillTranslationMatch(translation: latest, isStale: true)
    }
}
