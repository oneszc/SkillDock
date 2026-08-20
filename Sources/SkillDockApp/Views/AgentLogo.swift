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

struct AgentMenuLogo: View {
    let target: AgentTarget
    var installed = true
    var size: CGFloat = 13

    var body: some View {
        Group {
            if let image = target.logoImage(installed: installed) {
                Image(nsImage: image.scaledToFit(side: size))
            } else {
                Image(systemName: "app.dashed")
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(width: size, height: size)
    }
}

private extension NSImage {
    func scaledToFit(side: CGFloat) -> NSImage {
        let output = NSImage(size: NSSize(width: side, height: side))
        let scale = min(side / size.width, side / size.height)
        let fittedSize = NSSize(width: size.width * scale, height: size.height * scale)
        let origin = NSPoint(
            x: (side - fittedSize.width) / 2,
            y: (side - fittedSize.height) / 2
        )

        output.lockFocus()
        draw(
            in: NSRect(origin: origin, size: fittedSize),
            from: .zero,
            operation: .copy,
            fraction: 1
        )
        output.unlockFocus()
        return output
    }
}

private extension AgentTarget {
    func logoImage(installed: Bool) -> NSImage? {
        guard let logoAssetName else { return nil }
        let name = installed ? logoAssetName : "\(logoAssetName)-gray"
        for fileExtension in ["png", "svg"] {
            if let url = Bundle.module.url(forResource: name, withExtension: fileExtension),
               let image = NSImage(contentsOf: url) {
                return image
            }
        }
        return nil
    }
}
