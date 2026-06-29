import Foundation

public struct SkillRecord: Identifiable, Equatable, Sendable {
    public let skill: Skill
    public let note: SkillNote?
    public let isNoteStale: Bool
    public let remoteSource: RemoteSkillSource?
    public let translation: SkillTranslation?
    public let isTranslationStale: Bool
    public let physicalCopies: [SkillPhysicalCopy]

    public var id: String { skill.id }
    public var hasLibraryCopy: Bool {
        physicalCopies.contains { $0.source == .library }
    }

    public var hasInstalledCopy: Bool {
        !skill.installation.agentIDs.isEmpty || physicalCopies.contains {
            if case .agent = $0.source { return true }
            return false
        }
    }

    public var hasSystemCopy: Bool {
        physicalCopies.contains { $0.isSystem }
    }

    public var systemCopy: SkillPhysicalCopy? {
        physicalCopies.first { $0.isSystem }
    }

    public init(
        skill: Skill,
        note: SkillNote?,
        isNoteStale: Bool,
        remoteSource: RemoteSkillSource? = nil,
        translation: SkillTranslation? = nil,
        isTranslationStale: Bool = false,
        physicalCopies: [SkillPhysicalCopy] = []
    ) {
        self.skill = skill
        self.note = note
        self.isNoteStale = isNoteStale
        self.remoteSource = remoteSource
        self.translation = translation
        self.isTranslationStale = isTranslationStale
        self.physicalCopies = physicalCopies.isEmpty ? [skill.physicalCopy] : physicalCopies
    }
}

public struct SkillLibraryBuilder: Sendable {
    public init() {}

    public func build(
        skills: [Skill],
        notes: [SkillNote],
        translations: [SkillTranslation] = []
    ) -> [SkillRecord] {
        let groups = Dictionary(grouping: skills) {
            "\($0.name.lowercased()):\($0.contentHash)"
        }

        return groups.values.compactMap { group in
            guard var preferred = group.min(by: {
                sourcePriority($0.source) < sourcePriority($1.source)
            }) else {
                return nil
            }

            let installedAgentIDs = Set(
                group.compactMap { skill -> String? in
                    guard case .agent(let id) = skill.source else { return nil }
                    return id
                }
            )
            preferred.installation = SkillInstallation(agentIDs: installedAgentIDs)
            let physicalCopies = group
                .map(\.physicalCopy)
                .sorted {
                    if sourcePriority($0.source) == sourcePriority($1.source) {
                        return $0.path.path.localizedCaseInsensitiveCompare($1.path.path) == .orderedAscending
                    }
                    return sourcePriority($0.source) < sourcePriority($1.source)
                }

            let noteMatch = matchNote(for: preferred, notes: notes)
            let translationMatch = matchTranslation(for: preferred, translations: translations)
            return SkillRecord(
                skill: preferred,
                note: noteMatch?.note,
                isNoteStale: noteMatch?.isStale ?? false,
                translation: translationMatch?.translation,
                isTranslationStale: translationMatch?.isStale ?? false,
                physicalCopies: physicalCopies
            )
        }
        .sorted {
            $0.skill.name.localizedCaseInsensitiveCompare($1.skill.name) == .orderedAscending
        }
    }

    private func sourcePriority(_ source: SkillSource) -> Int {
        switch source {
        case .library: 0
        case .agent: 1
        }
    }

    private func matchNote(for skill: Skill, notes: [SkillNote]) -> SkillNoteMatch? {
        let candidates = notes.filter {
            $0.key.name == skill.name && $0.key.source == skill.source
        }
        if let exact = candidates.first(where: { $0.key.contentHash == skill.contentHash }) {
            return SkillNoteMatch(note: exact, isStale: false)
        }
        guard let latest = candidates.max(by: { $0.updatedAt < $1.updatedAt }) else {
            return nil
        }
        return SkillNoteMatch(note: latest, isStale: true)
    }

    private func matchTranslation(
        for skill: Skill,
        translations: [SkillTranslation]
    ) -> SkillTranslationMatch? {
        let candidates = translations.filter {
            $0.skillName == skill.name && $0.source == skill.source
        }
        if let exact = candidates.first(where: { $0.contentHash == skill.contentHash }) {
            return SkillTranslationMatch(translation: exact, isStale: false)
        }
        guard let latest = candidates.max(by: { $0.generatedAt < $1.generatedAt }) else {
            return nil
        }
        return SkillTranslationMatch(translation: latest, isStale: true)
    }
}
