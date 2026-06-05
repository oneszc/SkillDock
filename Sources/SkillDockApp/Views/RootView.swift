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
                SettingsView(model: model)
            } else {
                SkillDetailView(model: model, record: model.selectedRecord)
            }
        }
        .searchable(text: $model.searchQuery, prompt: "Search Skills")
        .toolbar {
            ToolbarItem {
                Button {
                    Task { await model.requestImport() }
                } label: {
                    Label("Import Skill", systemImage: "plus")
                }
            }
            ToolbarItemGroup {
                Button(action: model.revealSelectedInFinder) {
                    Label("Reveal in Finder", systemImage: "folder")
                }
                .disabled(model.selectedRecord == nil)
                Button(action: model.copySelectedPath) {
                    Label("Copy Path", systemImage: "doc.on.doc")
                }
                .disabled(model.selectedRecord == nil)
            }
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
        .onChange(of: model.selectionID) { _, _ in
            Task { await model.loadSelectedDetail() }
        }
        .confirmationDialog(
            "Replace the existing Skill?",
            isPresented: Binding(
                get: { model.pendingOverwrite != nil },
                set: { if !$0 { model.pendingOverwrite = nil } }
            )
        ) {
            Button("Replace", role: .destructive) {
                Task { await model.confirmOverwrite() }
            }
            Button("Cancel", role: .cancel) {
                model.pendingOverwrite = nil
            }
        } message: {
            Text("The existing folder will be replaced only after you confirm.")
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
        .alert(
            "SkillDock",
            isPresented: Binding(
                get: { model.operationMessage != nil },
                set: { if !$0 { model.operationMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(model.operationMessage ?? "")
        }
        .frame(minWidth: 980, minHeight: 620)
    }
}
