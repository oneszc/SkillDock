import SkillDockCore
import SwiftUI

struct AppearanceModePicker: View {
    let selection: AppearanceMode
    let onSelect: (AppearanceMode) -> Void

    var body: some View {
        HStack(spacing: 18) {
            Spacer()
            ForEach(AppearanceMode.allCases, id: \.self) { mode in
                Button {
                    onSelect(mode)
                } label: {
                    VStack(spacing: 8) {
                        AppearancePreview(mode: mode)
                            .overlay {
                                RoundedRectangle(cornerRadius: 9)
                                    .stroke(
                                        selection == mode ? Color.accentColor : .clear,
                                        lineWidth: 3
                                    )
                                    .padding(-4)
                            }
                        Text(mode.title)
                            .foregroundStyle(selection == mode ? .primary : .secondary)
                            .fontWeight(selection == mode ? .semibold : .regular)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(mode.title) appearance")
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

private struct AppearancePreview: View {
    let mode: AppearanceMode

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(background)
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(sidebar)
                    .frame(width: 28)
                    .padding(4)
                Spacer()
            }
            VStack {
                HStack(spacing: 3) {
                    Circle().fill(.red).frame(width: 5, height: 5)
                    Circle().fill(.yellow).frame(width: 5, height: 5)
                    Circle().fill(.green).frame(width: 5, height: 5)
                    Spacer()
                }
                Spacer()
            }
            .padding(7)
        }
        .frame(width: 104, height: 58)
        .overlay {
            RoundedRectangle(cornerRadius: 7)
                .stroke(.separator, lineWidth: 1)
        }
    }

    private var background: AnyShapeStyle {
        switch mode {
        case .system:
            AnyShapeStyle(
                LinearGradient(
                    colors: [.white, Color(nsColor: .darkGray)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        case .light:
            AnyShapeStyle(Color.white)
        case .dark:
            AnyShapeStyle(Color(nsColor: .darkGray))
        }
    }

    private var sidebar: Color {
        switch mode {
        case .system: Color.accentColor.opacity(0.42)
        case .light: Color.accentColor.opacity(0.28)
        case .dark: Color.accentColor.opacity(0.58)
        }
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
}
