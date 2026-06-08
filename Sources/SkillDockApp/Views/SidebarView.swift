import SwiftUI

struct SidebarView: View {
    @Binding var selection: NavigationSection

    var body: some View {
        List(NavigationSection.allCases, selection: $selection) { section in
            Label(section.rawValue, systemImage: section.systemImage)
                .font(.system(size: 13))
                .padding(.vertical, 1)
                .tag(section)
        }
        .listStyle(.sidebar)
        .navigationTitle("SkillDock")
    }
}
