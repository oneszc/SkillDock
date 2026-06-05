import SkillDockCore
import SwiftUI

struct SettingsView: View {
    let settings: SkillSettings

    var body: some View {
        Form {
            Section("Skill Locations") {
                LabeledContent("Library", value: settings.libraryPath.path)
                LabeledContent("Codex", value: settings.codexPath.path)
                LabeledContent("Claude", value: settings.claudePath.path)
            }
            Section("Behavior") {
                LabeledContent("System Skills", value: settings.showSystemSkills ? "Shown" : "Hidden")
                LabeledContent("Conflict Strategy", value: settings.defaultConflictStrategy.rawValue.capitalized)
            }
        }
        .formStyle(.grouped)
        .padding()
        .navigationTitle("Settings")
    }
}
