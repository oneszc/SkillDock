import SwiftUI

struct TranslationEmptyView: View {
    let state: TranslationContentState
    let onGenerate: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        Group {
            switch state {
            case .missingConfiguration:
                ContentUnavailableView {
                    Label("Translation Not Configured", systemImage: "key")
                } description: {
                    Text("Configure your DeepSeek API Key in Settings.")
                } actions: {
                    Button("Open Settings", action: onOpenSettings)
                }
            case .empty:
                ContentUnavailableView {
                    Label("No Translation Yet", systemImage: "character.book.closed")
                } description: {
                    Text("SkillDock will send the current SKILL.md to DeepSeek to generate a Chinese translation.")
                } actions: {
                    Button("Generate Translation", action: onGenerate)
                        .buttonStyle(.borderedProminent)
                }
            case .generating:
                ContentUnavailableView {
                    ProgressView()
                    Text("Generating Translation")
                } description: {
                    Text("You can continue reading the original while this completes.")
                }
            case .failed(let message):
                ContentUnavailableView {
                    Label("Translation Failed", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("Retry", action: onGenerate)
                }
            case .original, .available:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
