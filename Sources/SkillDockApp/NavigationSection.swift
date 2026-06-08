import Foundation

enum NavigationSection: String, CaseIterable, Identifiable {
    case library = "Library"
    case installed = "Installed"
    case system = "System"

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .library: "folder"
        case .installed: "square.and.arrow.down"
        case .system: "lock.shield"
        }
    }
}
