import AppKit
import SkillDockCore
import SwiftUI

struct AgentLogo: View {
    let target: InstallTarget
    var installed = true
    var size: CGFloat = 20

    var body: some View {
        logo
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }

    private var logo: Image {
        if let image = target.logoImage(installed: installed) {
            Image(nsImage: image)
        } else {
            Image(systemName: "app.dashed")
        }
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

    func logoImage(installed: Bool) -> NSImage? {
        let name = installed ? resourceName : "\(resourceName)-gray"
        guard let url = Bundle.module.url(forResource: name, withExtension: "svg") else {
            return nil
        }
        return NSImage(contentsOf: url)
    }
}
