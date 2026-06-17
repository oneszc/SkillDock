import AppKit
import SkillDockCore
import SwiftUI

struct AgentLogo: View {
    let target: AgentTarget
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

private extension AgentTarget {
    func logoImage(installed: Bool) -> NSImage? {
        guard let logoAssetName else { return nil }
        let name = installed ? logoAssetName : "\(logoAssetName)-gray"
        guard let url = Bundle.module.url(forResource: name, withExtension: "svg") else {
            return nil
        }
        return NSImage(contentsOf: url)
    }
}
