import SkillDockCore
import SwiftUI

struct AgentLogo: View {
    let target: InstallTarget
    var installed = true
    var size: CGFloat = 20

    var body: some View {
        Image(target.resourceName, bundle: .module)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .grayscale(installed ? 0 : 1)
            .opacity(installed ? 1 : 0.28)
    }
}

extension InstallTarget {
    var displayName: String {
        switch self {
        case .codex: "Codex"
        case .claude: "Claude"
        }
    }

    var resourceName: String {
        switch self {
        case .codex: "codex"
        case .claude: "claude"
        }
    }
}
