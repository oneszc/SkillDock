import Foundation

public struct SkillSearch: Sendable {
    public init() {}

    public func filter(
        _ records: [SkillRecord],
        query: String,
        systemOnly: Bool = false
    ) -> [SkillRecord] {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return records.filter { record in
            guard !systemOnly || record.skill.isSystem else { return false }
            guard !normalizedQuery.isEmpty else { return true }
            return searchableText(for: record).contains(normalizedQuery)
        }
    }

    private func searchableText(for record: SkillRecord) -> String {
        let skill = record.skill
        let note = record.note
        return [
            skill.name,
            skill.description ?? "",
            skill.path.path,
            skill.source.displayName,
            note?.chineseDescription ?? "",
            note?.tags.joined(separator: " ") ?? "",
            note?.useCases.joined(separator: " ") ?? "",
            note?.riskNote ?? "",
            note?.usageNote ?? ""
        ]
        .joined(separator: " ")
        .lowercased()
    }
}
