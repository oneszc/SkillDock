import Foundation

enum NavigationSection: String, CaseIterable, Identifiable {
    case library = "Library"
    case installed = "Installed"
    case system = "System"
    case settings = "Settings"

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .library: "books.vertical"
        case .installed: "checkmark.circle"
        case .system: "lock.shield"
        case .settings: "gearshape"
        }
    }
}
