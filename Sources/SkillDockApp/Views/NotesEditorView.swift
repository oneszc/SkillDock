import SkillDockCore
import SwiftUI

struct NotesEditorView: View {
    let record: SkillRecord
    let onSave: (String, String, String, String, RiskLevel, String) async -> Void

    @State private var chineseName = ""
    @State private var chineseDescription = ""
    @State private var tags = ""
    @State private var usageNote = ""
    @State private var riskLevel: RiskLevel = .unknown
    @State private var riskNote = ""

    var body: some View {
        Form {
            Section("Chinese Understanding") {
                TextField("Chinese name", text: $chineseName)
                TextField("Chinese description", text: $chineseDescription, axis: .vertical)
                    .lineLimit(3...6)
                TextField("Tags, separated by commas", text: $tags)
                TextField("Usage notes", text: $usageNote, axis: .vertical)
                    .lineLimit(3...6)
            }
            Section("Risk") {
                Picker("Risk level", selection: $riskLevel) {
                    ForEach(RiskLevel.allCases, id: \.self) {
                        Text($0.rawValue.capitalized).tag($0)
                    }
                }
                TextField("Risk notes", text: $riskNote, axis: .vertical)
                    .lineLimit(2...5)
            }
            HStack {
                Spacer()
                Button("Save Notes") {
                    Task {
                        await onSave(
                            chineseName,
                            chineseDescription,
                            tags,
                            usageNote,
                            riskLevel,
                            riskNote
                        )
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .formStyle(.grouped)
        .onAppear(perform: loadNote)
        .onChange(of: record.id) { _, _ in loadNote() }
    }

    private func loadNote() {
        chineseName = record.note?.chineseName ?? ""
        chineseDescription = record.note?.chineseDescription ?? ""
        tags = record.note?.tags.joined(separator: ", ") ?? ""
        usageNote = record.note?.usageNote ?? ""
        riskLevel = record.note?.riskLevel ?? .unknown
        riskNote = record.note?.riskNote ?? ""
    }
}
