import Foundation

public actor SkillWorkspaceService {
    private let notesStore: NotesStore
    private let fileOperator: SkillFileOperator
    private let fileManager: FileManager

    public init(
        notesStore: NotesStore = .init(),
        fileOperator: SkillFileOperator = .init(),
        fileManager: FileManager = .default
    ) {
        self.notesStore = notesStore
        self.fileOperator = fileOperator
        self.fileManager = fileManager
    }

    public func markdown(for skillDirectory: URL) throws -> String {
        try String(
            contentsOf: skillDirectory.appendingPathComponent("SKILL.md"),
            encoding: .utf8
        )
    }

    public func fileTree(for skillDirectory: URL) throws -> [String] {
        guard let enumerator = fileManager.enumerator(
            at: skillDirectory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: []
        ) else {
            return []
        }

        let rootPath = skillDirectory.resolvingSymlinksInPath().path
        var paths: [String] = []
        for case let item as URL in enumerator {
            let relativePath = item.resolvingSymlinksInPath().path
                .replacingOccurrences(of: rootPath + "/", with: "")
            paths.append(relativePath)
        }
        return paths.sorted {
            $0.localizedStandardCompare($1) == .orderedAscending
        }
    }

    public func save(note: SkillNote) async throws {
        try await notesStore.upsert(note)
    }

    public func importSkill(
        from source: URL,
        settings: SkillSettings,
        strategy: ConflictStrategy
    ) async throws -> SkillFileOperationResult {
        try await fileOperator.copySkill(
            from: source,
            to: settings.libraryPath,
            strategy: strategy
        )
    }

    public func installSkill(
        from source: URL,
        target: InstallTarget,
        settings: SkillSettings,
        strategy: ConflictStrategy,
        isSystemSkill: Bool = false
    ) async throws -> SkillFileOperationResult {
        let destination = switch target {
        case .codex: settings.codexPath
        case .claude: settings.claudePath
        }
        return try await fileOperator.copySkill(
            from: source,
            to: destination,
            strategy: strategy,
            isSystemSkill: isSystemSkill
        )
    }
}
