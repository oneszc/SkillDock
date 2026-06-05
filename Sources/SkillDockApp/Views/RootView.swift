import SwiftUI

struct RootView: View {
    @State private var model = AppModel()

    var body: some View {
        @Bindable var model = model

        NavigationSplitView {
            SidebarView(selection: $model.navigationSection)
                .navigationSplitViewColumnWidth(min: 180, ideal: 210, max: 260)
        } content: {
            SkillListView(
                records: model.filteredRecords,
                selectionID: $model.selectionID
            )
            .navigationSplitViewColumnWidth(min: 280, ideal: 340, max: 420)
        } detail: {
            if model.navigationSection == .settings {
                SettingsView(settings: model.settings)
            } else {
                SkillDetailView(record: model.selectedRecord)
            }
        }
        .searchable(text: $model.searchQuery, prompt: "Search Skills")
        .toolbar {
            ToolbarItem {
                Button {
                    Task { await model.refresh() }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .disabled(model.isRefreshing)
            }
        }
        .task {
            await model.start()
        }
        .alert(
            "SkillDock could not refresh",
            isPresented: Binding(
                get: { model.errorMessage != nil },
                set: { if !$0 { model.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(model.errorMessage ?? "")
        }
        .frame(minWidth: 980, minHeight: 620)
    }
}
