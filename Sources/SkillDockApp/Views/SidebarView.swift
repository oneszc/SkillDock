import SwiftUI

struct SidebarView: View {
    @Binding var selection: NavigationSection

    var body: some View {
        List(NavigationSection.allCases, selection: $selection) { section in
            Label(section.rawValue, systemImage: section.systemImage)
                .font(.body)
                .padding(.vertical, 3)
                .tag(section)
        }
        .listStyle(.sidebar)
        .navigationTitle("SkillDock")
    }
}
