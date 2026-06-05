import SkillDockCore
import SwiftUI

struct SkillListView: View {
    let records: [SkillRecord]
    @Binding var selectionID: SkillRecord.ID?

    var body: some View {
        if records.isEmpty {
            ContentUnavailableView(
                "No Skills",
                systemImage: "tray",
                description: Text("Refresh or choose another section.")
            )
        } else {
            List(records, selection: $selectionID) { record in
                SkillRowView(record: record)
                    .tag(record.id)
            }
            .navigationTitle("\(records.count) Skills")
        }
    }
}
