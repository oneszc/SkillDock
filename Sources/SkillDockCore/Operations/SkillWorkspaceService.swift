import Foundation

public enum SkillWorkspaceServiceError: Error, Equatable, Sendable {
    case installedSkillNotFound
    case installedSkillAmbiguous
}

extension SkillWorkspaceServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .installedSkillNotFound:
            "The installed Skill changed or could not be found. Refresh and try again."
        case .installedSkillAmbiguous:
            "More than one matching installed Skill was found. No files were removed."
        }
    }
}

public actor SkillWorkspaceService {
    private let notesStore: NotesStore
    private let fileOperator: SkillFileOperator
    private let fileManager: FileManager
    private let beforeUninstallFinalValidation: (@Sendable (URL) throws -> Void)?

    public init(
        notesStore: NotesStore = .init(),
        fileOperator: SkillFileOperator = .init(),
        fileManager: FileManager = .default
    ) {
        self.notesStore = notesStore
        self.fileOperator = fileOperator
        self.fileManager = fileManager
        self.beforeUninstallFinalValidation = nil
    }

    init(beforeUninstallFinalValidation: @escaping @Sendable (URL) throws -> Void) {
        self.notesStore = .init()
        self.fileOperator = .init()
        self.fileManager = .default
        self.beforeUninstallFinalValidation = beforeUninstallFinalValidation
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

    public func save(draft: NoteDraft, for skill: Skill) async throws {
        try await notesStore.upsert(
            SkillNote(
                key: SkillNoteKey(
                    name: skill.name,
                    source: skill.source,
                    contentHash: skill.contentHash
                ),
                chineseName: draft.chineseName,
                chineseDescription: draft.chineseDescription,
                tags: draft.tags,
                useCases: draft.useCases,
                riskLevel: draft.riskLevel,
                riskNote: draft.riskNote,
                usageNote: draft.usageNote,
                updatedAt: Date()
            )
        )
    }

    public func noteSuggestions() async throws -> NoteSuggestions {
        try await notesStore.suggestions()
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

    public func importSkill(
        preview: ImportPreview,
        settings: SkillSettings
    ) async throws -> SkillFileOperationResult {
        try await fileOperator.copySkill(
            from: preview.sourceURL,
            to: settings.libraryPath,
            strategy: preview.strategy
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

    public func uninstallSkill(
        named name: String,
        contentHash: String,
        target: InstallTarget,
        settings: SkillSettings,
        isSystemSkill: Bool = false
    ) async throws {
        guard !isSystemSkill else {
            throw SkillFileOperationError.systemSkillIsReadOnly
        }

        let targetRoot = switch target {
        case .codex: settings.codexPath
        case .claude: settings.claudePath
        }
        let otherAgentRoot = switch target {
        case .codex: settings.claudePath
        case .claude: settings.codexPath
        }
        let source: SkillSource = switch target {
        case .codex: .codex
        case .claude: .claude
        }
        let resolvedLibraryRoot = resolved(settings.libraryPath)
        guard !path(resolved(targetRoot), isSameOrInside: resolvedLibraryRoot) else {
            throw SkillFileOperationError.destinationOutsideRoot
        }

        let children = (try? fileManager.contentsOfDirectory(
            at: targetRoot,
            includingPropertiesForKeys: [.fileResourceIdentifierKey]
        )) ?? []
        var matches: [Skill] = []
        for child in children {
            let scannedSkills = await SkillScanner()
                .scan([ScanLocation(root: child, source: source)])
            matches.append(contentsOf: scannedSkills.filter {
                $0.name == name
                    && $0.contentHash == contentHash
                    && (pathsReferToSameFile($0.path, child) || $0.isSystem)
            })
        }
        guard let installedSkill = matches.first else {
            throw SkillWorkspaceServiceError.installedSkillNotFound
        }
        guard matches.count == 1 else {
            throw SkillWorkspaceServiceError.installedSkillAmbiguous
        }
        guard !installedSkill.isSystem else {
            throw SkillFileOperationError.systemSkillIsReadOnly
        }

        let resolvedInstalledSkill = resolved(installedSkill.path)
        guard !pathsOverlap(resolvedInstalledSkill, resolvedLibraryRoot) else {
            throw SkillFileOperationError.destinationOutsideRoot
        }
        guard !pathsOverlap(resolvedInstalledSkill, resolved(otherAgentRoot)) else {
            throw SkillFileOperationError.destinationOutsideRoot
        }

        try beforeUninstallFinalValidation?(installedSkill.path)
        guard let finalInstalledSkill = await exactSkill(
            at: installedSkill.path,
            named: name,
            contentHash: contentHash,
            source: source
        ) else {
            throw SkillWorkspaceServiceError.installedSkillNotFound
        }
        guard !finalInstalledSkill.isSystem else {
            throw SkillFileOperationError.systemSkillIsReadOnly
        }

        try await fileOperator.removeSkill(
            named: finalInstalledSkill.path.lastPathComponent,
            from: targetRoot,
            isSystemSkill: finalInstalledSkill.isSystem
        )
    }

    private func exactSkill(
        at target: URL,
        named name: String,
        contentHash: String,
        source: SkillSource
    ) async -> Skill? {
        let scannedSkills = await SkillScanner()
            .scan([ScanLocation(root: target, source: source)])
        return scannedSkills.first {
            $0.name == name
                && $0.contentHash == contentHash
                && pathsReferToSameFile($0.path, target)
        }
    }

    private func resolved(_ url: URL) -> URL {
        url.resolvingSymlinksInPath().standardizedFileURL
    }

    private func pathsOverlap(_ lhs: URL, _ rhs: URL) -> Bool {
        path(lhs, isSameOrInside: rhs) || path(rhs, isSameOrInside: lhs)
    }

    private func path(_ candidate: URL, isSameOrInside root: URL) -> Bool {
        candidate.pathComponents.starts(with: root.pathComponents)
            || ancestors(of: candidate).contains { pathsReferToSameFile($0, root) }
    }

    private func pathsReferToSameFile(_ lhs: URL, _ rhs: URL) -> Bool {
        if resolved(lhs).pathComponents == resolved(rhs).pathComponents {
            return true
        }
        let keys: Set<URLResourceKey> = [.fileResourceIdentifierKey]
        guard let lhsIdentifier = try? lhs.resourceValues(forKeys: keys).fileResourceIdentifier,
              let rhsIdentifier = try? rhs.resourceValues(forKeys: keys).fileResourceIdentifier,
              let lhsObject = lhsIdentifier as? NSObject
        else {
            return false
        }
        return lhsObject.isEqual(rhsIdentifier)
    }

    private func ancestors(of url: URL) -> [URL] {
        var ancestors: [URL] = []
        var current = url
        while current.pathComponents.count > 1 {
            ancestors.append(current)
            current.deleteLastPathComponent()
        }
        return ancestors
    }
}
