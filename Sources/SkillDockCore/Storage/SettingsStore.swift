import Foundation

public actor SettingsStore {
    private let store: JSONStore<SkillSettings>

    public init(
        directory: URL = NotesStore.defaultDirectory,
        defaultSettings: SkillSettings = .defaults()
    ) {
        store = JSONStore(
            fileURL: directory.appendingPathComponent("settings.json"),
            defaultValue: defaultSettings
        )
    }

    public func load() throws -> SkillSettings {
        try store.load()
    }

    public func save(_ settings: SkillSettings) throws {
        try store.save(settings)
    }
}
