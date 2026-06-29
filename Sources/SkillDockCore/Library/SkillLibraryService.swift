import Foundation

public actor SkillLibraryService {
    private let scanner: SkillScanner
    private let notesStore: NotesStore
    private let translationStore: TranslationStore
    private let remoteSourceStore: RemoteSourceStore
    private let builder: SkillLibraryBuilder

    public init(
        scanner: SkillScanner = .init(),
        notesStore: NotesStore = .init(),
        translationStore: TranslationStore = .init(),
        remoteSourceStore: RemoteSourceStore = .init(),
        builder: SkillLibraryBuilder = .init()
    ) {
        self.scanner = scanner
        self.notesStore = notesStore
        self.translationStore = translationStore
        self.remoteSourceStore = remoteSourceStore
        self.builder = builder
    }

    public func refresh(settings: SkillSettings) async throws -> [SkillRecord] {
        let agentLocations = settings.agentTargets
            .filter(\.isEnabled)
            .map { ScanLocation(root: $0.path, source: .agent($0.id)) }
        let skills = await scanner.scan(
            [ScanLocation(root: settings.libraryPath, source: .library)] + agentLocations
        )
        let notes = try await notesStore.load()
        let translations = try await translationStore.load()
        let remoteSources = try await remoteSourceStore.load()
        return builder
            .build(skills: skills, notes: notes, translations: translations)
            .map { record in
                SkillRecord(
                    skill: record.skill,
                    note: record.note,
                    isNoteStale: record.isNoteStale,
                    remoteSource: remoteSource(for: record.skill, in: remoteSources),
                    translation: record.translation,
                    isTranslationStale: record.isTranslationStale,
                    physicalCopies: record.physicalCopies
                )
            }
            .filter { settings.showSystemSkills || !$0.skill.isSystem }
    }

    private func remoteSource(
        for skill: Skill,
        in sources: [RemoteSkillSource]
    ) -> RemoteSkillSource? {
        guard skill.source == .library else { return nil }
        let skillPath = normalizedPath(skill.path)
        return sources.first { normalizedPath($0.destination) == skillPath }
    }

    private func normalizedPath(_ url: URL) -> String {
        url.standardizedFileURL.path
    }
}
