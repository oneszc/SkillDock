import Foundation

public struct SkillLibrarySnapshot: Sendable {
    public let records: [SkillRecord]
    public let issues: [SkillScanIssue]

    public init(records: [SkillRecord], issues: [SkillScanIssue]) {
        self.records = records
        self.issues = issues
    }
}

public actor SkillLibraryService {
    private let scanner: SkillScanner
    private let notesStore: NotesStore
    private let translationStore: TranslationStore
    private let remoteSourceStore: RemoteSourceStore
    private let builder: SkillLibraryBuilder
    private let homeDirectory: URL

    public init(
        scanner: SkillScanner = .init(),
        notesStore: NotesStore = .init(),
        translationStore: TranslationStore = .init(),
        remoteSourceStore: RemoteSourceStore = .init(),
        builder: SkillLibraryBuilder = .init(),
        homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser
    ) {
        self.scanner = scanner
        self.notesStore = notesStore
        self.translationStore = translationStore
        self.remoteSourceStore = remoteSourceStore
        self.builder = builder
        self.homeDirectory = homeDirectory
    }

    public func refresh(settings: SkillSettings) async throws -> SkillLibrarySnapshot {
        let systemRoots = settings.agentTargets
            .filter(\.supportsSystemSkills)
            .map { $0.path.appendingPathComponent(".system", isDirectory: true) }
        let agentLocations = settings.agentTargets
            .filter(\.isEnabled)
            .map { target in
                ScanLocation(
                    root: target.path,
                    source: .agent(target.id),
                    excludedRoots: target.supportsSystemSkills
                        ? [target.path.appendingPathComponent(".system", isDirectory: true)]
                        : []
                )
            }
        var availableLocations = [
            ScanLocation(
                root: homeDirectory.appendingPathComponent(".agents/skills", isDirectory: true),
                source: .available(.personal)
            )
        ]
        if settings.showSystemSkills {
            availableLocations += systemRoots.map {
                ScanLocation(root: $0, source: .available(.system))
            }
        }
        let scanResult = await scanner.scan(
            [ScanLocation(root: settings.libraryPath, source: .library)]
                + agentLocations
                + availableLocations
        )
        let notes = try await notesStore.load()
        let translations = try await translationStore.load()
        let remoteSources = try await remoteSourceStore.load()
        let records = builder
            .build(skills: scanResult.skills, notes: notes, translations: translations)
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
        return SkillLibrarySnapshot(records: records, issues: scanResult.issues)
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
