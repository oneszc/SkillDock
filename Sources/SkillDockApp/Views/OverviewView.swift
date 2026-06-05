import SkillDockCore
import SwiftUI

struct OverviewView: View {
    let record: SkillRecord

    var body: some View {
        Form {
            Section("Identity") {
                LabeledContent("Source", value: record.skill.source.displayName)
                LabeledContent("Path", value: record.skill.path.path)
            }
            Section("Status") {
                LabeledContent("Codex", value: record.skill.installation.codex ? "Installed" : "Not installed")
                LabeledContent("Claude", value: record.skill.installation.claude ? "Installed" : "Not installed")
                LabeledContent("Scripts", value: record.skill.hasScripts ? "Review recommended" : "None")
                LabeledContent("Risk", value: record.note?.riskLevel.rawValue.capitalized ?? "Unknown")
            }
        }
        .formStyle(.grouped)
    }
}
