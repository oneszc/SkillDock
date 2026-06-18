import Foundation

public enum TranslationProviderID {
    public static let deepSeek = "deepseek"
}

public enum DeepSeekModel: String, Codable, CaseIterable, Sendable {
    case flash = "deepseek-v4-flash"
    case pro = "deepseek-v4-pro"
}

public struct TranslationSettings: Codable, Equatable, Sendable {
    public var providerID: String
    public var model: String

    public init(
        providerID: String = TranslationProviderID.deepSeek,
        model: String = DeepSeekModel.flash.rawValue
    ) {
        self.providerID = providerID
        self.model = model
    }
}
