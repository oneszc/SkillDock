import SkillDockCore

enum TranslationLanguage: String, CaseIterable, Identifiable {
    case original
    case translated

    var id: Self { self }
    var title: String { self == .original ? "原文" : "译文" }
}

enum TranslationContentState: Equatable {
    case original
    case missingConfiguration
    case empty
    case generating
    case available(isStale: Bool)
    case failed(String)
}

struct TranslationPresentation {
    let record: SkillRecord
    let originalMarkdown: String
    let language: TranslationLanguage
    let showsMarkdown: Bool
    let isGenerating: Bool
    let errorMessage: String?
    let hasAPIKey: Bool

    var title: String { record.skill.name }

    var description: String? {
        guard showsMarkdown, language == .translated, let translation = record.translation else {
            return record.skill.description
        }
        return translation.translatedDescription
    }

    var markdown: String {
        guard showsMarkdown, language == .translated, let translation = record.translation else {
            return originalMarkdown
        }
        return translation.translatedMarkdown
    }

    var state: TranslationContentState {
        guard showsMarkdown, language == .translated else { return .original }
        if isGenerating { return .generating }
        if let errorMessage { return .failed(errorMessage) }
        if record.translation != nil { return .available(isStale: record.isTranslationStale) }
        return hasAPIKey ? .empty : .missingConfiguration
    }
}
