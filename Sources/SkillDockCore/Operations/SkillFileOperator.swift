import Foundation

public enum SkillFileOperationError: Error, Equatable, Sendable {
    case missingSkillMarkdown
    case systemSkillIsReadOnly
    case destinationOutsideRoot
}

public enum SkillFileOperationResult: Equatable, Sendable {
    case copied(URL)
    case skipped(URL)
}

public actor SkillFileOperator {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func copySkill(
        from source: URL,
        to destinationRoot: URL,
        strategy: ConflictStrategy,
        isSystemSkill: Bool = false
    ) throws -> SkillFileOperationResult {
        guard !isSystemSkill else {
            throw SkillFileOperationError.systemSkillIsReadOnly
        }
        guard fileManager.fileExists(
            atPath: source.appendingPathComponent("SKILL.md").path
        ) else {
            throw SkillFileOperationError.missingSkillMarkdown
        }

        try fileManager.createDirectory(
            at: destinationRoot,
            withIntermediateDirectories: true
        )

        let destination = destinationRoot.appendingPathComponent(
            source.lastPathComponent,
            isDirectory: true
        )
        guard fileManager.fileExists(atPath: destination.path) else {
            try fileManager.copyItem(at: source, to: destination)
            return .copied(destination)
        }

        switch strategy {
        case .skip:
            return .skipped(destination)
        case .rename:
            let uniqueDestination = nextAvailableDestination(
                named: source.lastPathComponent,
                in: destinationRoot
            )
            try fileManager.copyItem(at: source, to: uniqueDestination)
            return .copied(uniqueDestination)
        case .overwrite:
            let temporaryDestination = destinationRoot.appendingPathComponent(
                ".skilldock-copy-\(UUID().uuidString)",
                isDirectory: true
            )
            try fileManager.copyItem(at: source, to: temporaryDestination)
            try fileManager.removeItem(at: destination)
            try fileManager.moveItem(at: temporaryDestination, to: destination)
            return .copied(destination)
        }
    }

    public func removeSkill(
        named name: String,
        from root: URL,
        isSystemSkill: Bool = false
    ) throws {
        guard !isSystemSkill else {
            throw SkillFileOperationError.systemSkillIsReadOnly
        }

        let standardizedRoot = root.standardizedFileURL
        let destination = root
            .appendingPathComponent(name, isDirectory: true)
            .standardizedFileURL
        guard destination.deletingLastPathComponent() == standardizedRoot else {
            throw SkillFileOperationError.destinationOutsideRoot
        }
        guard fileManager.fileExists(atPath: destination.path) else {
            return
        }

        try fileManager.removeItem(at: destination)
    }

    private func nextAvailableDestination(named name: String, in root: URL) -> URL {
        var suffix = 1
        while true {
            let label = suffix == 1 ? "\(name)-copy" : "\(name)-copy-\(suffix)"
            let candidate = root.appendingPathComponent(label, isDirectory: true)
            if !fileManager.fileExists(atPath: candidate.path) {
                return candidate
            }
            suffix += 1
        }
    }
}
