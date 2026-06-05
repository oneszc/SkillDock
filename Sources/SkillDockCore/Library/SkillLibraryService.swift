import Foundation

public actor SkillLibraryService {
    private let scanner: SkillScanner
    private let notesStore: NotesStore
    private let builder: SkillLibraryBuilder

    public init(
        scanner: SkillScanner = .init(),
        notesStore: NotesStore = .init(),
        builder: SkillLibraryBuilder = .init()
    ) {
        self.scanner = scanner
        self.notesStore = notesStore
        self.builder = builder
    }

    public func refresh(settings: SkillSettings) async throws -> [SkillRecord] {
        let skills = await scanner.scan([
            ScanLocation(root: settings.libraryPath, source: .library),
            ScanLocation(root: settings.codexPath, source: .codex),
            ScanLocation(root: settings.claudePath, source: .claude)
        ])
        let notes = try await notesStore.load()
        return builder
            .build(skills: skills, notes: notes)
            .filter { settings.showSystemSkills || !$0.skill.isSystem }
    }
}
