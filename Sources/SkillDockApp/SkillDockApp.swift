import AppKit
import SwiftUI

@main
struct SkillDockApp: App {
    @State private var model = AppModel()

    init() {
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    var body: some Scene {
        WindowGroup {
            RootView(model: model)
        }
        .defaultSize(width: 1180, height: 760)

        Window("Settings", id: "settings") {
            SettingsWindowView(model: model)
        }
        .defaultSize(width: 980, height: 650)
        .commands {
            SettingsCommands()
        }
    }
}
