import SkillDockCore
import SwiftUI

struct NotesEditorView: View {
    @Bindable var model: AppModel

    var body: some View {
        Form {
            Section("Chinese Understanding") {
                TextField(
                    "Chinese description",
                    text: $model.noteDraft.chineseDescription,
                    axis: .vertical
                )
                .lineLimit(3...6)
            }

            Section("Tags and Use Cases") {
                TokenEditorView(
                    title: "Tags",
                    suggestions: model.noteSuggestions.tags,
                    values: $model.noteDraft.tags
                )
                TokenEditorView(
                    title: "Use Cases",
                    suggestions: model.noteSuggestions.useCases,
                    values: $model.noteDraft.useCases
                )
            }

            Section("Risk and Guidance") {
                Picker("Risk level", selection: $model.noteDraft.riskLevel) {
                    ForEach(RiskLevel.allCases, id: \.self) {
                        Text($0.rawValue.capitalized).tag($0)
                    }
                }
                TextField("Risk notes", text: $model.noteDraft.riskNote, axis: .vertical)
                    .lineLimit(2...5)
                TextField("Usage notes", text: $model.noteDraft.usageNote, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section {
                saveStatus
            }
        }
        .formStyle(.grouped)
        .onChange(of: model.noteDraft) { _, draft in
            model.updateNoteDraft(draft)
        }
    }

    @ViewBuilder
    private var saveStatus: some View {
        switch model.noteSaveState {
        case .idle:
            EmptyView()
        case .pending:
            Label("Waiting to save", systemImage: "clock")
                .foregroundStyle(.secondary)
        case .saving:
            Label("Saving", systemImage: "arrow.triangle.2.circlepath")
                .foregroundStyle(.secondary)
        case .saved:
            Label("Saved", systemImage: "checkmark.circle")
                .foregroundStyle(.green)
        case .failed(let message):
            Label(message, systemImage: "exclamationmark.triangle")
                .foregroundStyle(.red)
        }
    }
}
