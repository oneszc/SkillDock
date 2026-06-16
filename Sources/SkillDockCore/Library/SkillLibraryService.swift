import Foundation

public actor SkillLibraryService {
    private let scanner: SkillScanner
    private let notesStore: NotesStore
    private let remoteSourceStore: RemoteSourceStore
    private let builder: SkillLibraryBuilder

    public init(
        scanner: SkillScanner = .init(),
        notesStore: NotesStore = .init(),
        remoteSourceStore: RemoteSourceStore = .init(),
        builder: SkillLibraryBuilder = .init()
    ) {
        self.scanner = scanner
        self.notesStore = notesStore
        self.remoteSourceStore = remoteSourceStore
        self.builder = builder
    }

    public func refresh(settings: SkillSettings) async throws -> [SkillRecord] {
        let skills = await scanner.scan([
            ScanLocation(root: settings.libraryPath, source: .library),
            ScanLocation(root: settings.codexPath, source: .codex),
            ScanLocation(root: settings.claudePath, source: .claude)
        ])
        let notes = try await notesStore.load()
        let remoteSources = try await remoteSourceStore.load()
        return builder
            .build(skills: skills, notes: notes)
            .map { record in
                SkillRecord(
                    skill: record.skill,
                    note: record.note,
                    isNoteStale: record.isNoteStale,
                    remoteSource: remoteSource(for: record.skill, in: remoteSources)
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
