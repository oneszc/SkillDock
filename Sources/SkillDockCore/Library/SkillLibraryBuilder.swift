import Foundation

public struct SkillRecord: Identifiable, Equatable, Sendable {
    public let skill: Skill
    public let note: SkillNote?
    public let isNoteStale: Bool

    public var id: String { skill.id }

    public init(skill: Skill, note: SkillNote?, isNoteStale: Bool) {
        self.skill = skill
        self.note = note
        self.isNoteStale = isNoteStale
    }
}

public struct SkillLibraryBuilder: Sendable {
    public init() {}

    public func build(skills: [Skill], notes: [SkillNote]) -> [SkillRecord] {
        let groups = Dictionary(grouping: skills) {
            "\($0.name.lowercased()):\($0.contentHash)"
        }

        return groups.values.compactMap { group in
            guard var preferred = group.min(by: {
                sourcePriority($0.source) < sourcePriority($1.source)
            }) else {
                return nil
            }

            preferred.installation = SkillInstallation(
                codex: group.contains(where: { $0.source == .codex }),
                claude: group.contains(where: { $0.source == .claude })
            )

            let noteMatch = matchNote(for: preferred, notes: notes)
            return SkillRecord(
                skill: preferred,
                note: noteMatch?.note,
                isNoteStale: noteMatch?.isStale ?? false
            )
        }
        .sorted {
            $0.skill.name.localizedCaseInsensitiveCompare($1.skill.name) == .orderedAscending
        }
    }

    private func sourcePriority(_ source: SkillSource) -> Int {
        switch source {
        case .library: 0
        case .codex: 1
        case .claude: 2
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
}
