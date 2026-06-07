import SkillDockCore
import SwiftUI

struct AppearanceModePicker: View {
    let selection: AppearanceMode
    let onSelect: (AppearanceMode) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 24) {
            Text("Appearance")
                .font(.title3)
                .foregroundStyle(.primary)

            Spacer()

            HStack(alignment: .top, spacing: 18) {
                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                    Button {
                        onSelect(mode)
                    } label: {
                        VStack(spacing: 8) {
                            Image(nsImage: mode.previewImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 46)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            selection == mode ? Color.accentColor : .clear,
                                            lineWidth: 3
                                        )
                                        .padding(-3)
                                }

                            Text(mode.title)
                                .font(.body)
                                .foregroundStyle(selection == mode ? .primary : .secondary)
                                .fontWeight(selection == mode ? .semibold : .regular)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(mode.title) appearance")
                }
            }
        }
        .padding(.vertical, 4)
    }
}

private extension AppearanceMode {
    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var resourceName: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var previewImage: NSImage {
        guard let url = Bundle.module.url(forResource: resourceName, withExtension: "png"),
              let image = NSImage(contentsOf: url)
        else {
            return NSImage()
        }
        return image
    }
}
