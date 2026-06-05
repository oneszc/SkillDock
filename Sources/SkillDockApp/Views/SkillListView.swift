import SkillDockCore
import SwiftUI

struct SkillListView: View {
    let records: [SkillRecord]
    let acceptsImportDrop: Bool
    @Binding var selectionID: SkillRecord.ID?
    let onImportDrop: ([URL]) -> Void
    @State private var isImportTargeted = false

    var body: some View {
        Group {
            if records.isEmpty {
                ContentUnavailableView(
                    "No Skills",
                    systemImage: "tray",
                    description: Text(
                        acceptsImportDrop
                            ? "Drop one Skill folder here or use Import Skill."
                            : "Refresh or choose another section."
                    )
                )
            } else {
                List(records, selection: $selectionID) { record in
                    SkillRowView(record: record)
                        .tag(record.id)
                }
                .navigationTitle("\(records.count) Skills")
            }
        }
        .dropDestination(for: URL.self) { urls, _ in
            guard acceptsImportDrop else { return false }
            onImportDrop(urls)
            return urls.count == 1
        } isTargeted: { targeted in
            isImportTargeted = acceptsImportDrop && targeted
        }
        .overlay {
            if isImportTargeted {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(
                        Color.accentColor,
                        style: StrokeStyle(lineWidth: 2, dash: [6])
                    )
                    .padding(6)
                    .allowsHitTesting(false)
            }
        }
    }
}
