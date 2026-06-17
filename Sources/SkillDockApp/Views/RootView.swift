import SkillDockCore
import SwiftUI

struct RootView: View {
    @Bindable var model: AppModel

    var body: some View {
        @Bindable var model = model

        skillBrowserLayout
        .task {
            await model.start()
        }
        .sheet(
            isPresented: Binding(
                get: { model.importPreview != nil },
                set: { if !$0 { model.importPreview = nil } }
            )
        ) {
            ImportPreviewView(model: model)
                .frame(minWidth: 620, minHeight: 560)
        }
        .sheet(isPresented: $model.isRemoteImportPresented) {
            RemoteImportView(appModel: model)
                .frame(minWidth: 720, minHeight: 620)
        }
        .sheet(isPresented: $model.isRemoteUpdatePreviewPresented) {
            if let update = model.remoteUpdate {
                RemoteUpdatePreviewView(model: model, update: update)
                    .frame(minWidth: 620, minHeight: 560)
            }
        }
        .onChange(of: model.selectionID) { _, _ in
            Task {
                await model.flushPendingNoteSave()
                await model.loadSelectedDetail()
                await model.loadNoteDraft()
            }
        }
        .confirmationDialog(
            "Replace the existing Skill?",
            isPresented: Binding(
                get: { model.pendingOverwrite != nil },
                set: { if !$0 { model.pendingOverwrite = nil } }
            )
        ) {
            Button("Replace", role: .destructive) {
                guard let pendingOverwrite = model.pendingOverwrite else { return }
                model.pendingOverwrite = nil
                Task { await model.confirmOverwrite(pendingOverwrite) }
            }
            Button("Cancel", role: .cancel) {
                model.pendingOverwrite = nil
            }
        } message: {
            Text("The existing folder will be replaced only after you confirm.")
        }
        .confirmationDialog(
            "Remove this Skill from \(model.pendingUninstall.map { model.agentDisplayName(id: $0.agentID) } ?? "Agent")?",
            isPresented: Binding(
                get: { model.pendingUninstall != nil },
                set: { if !$0 { model.pendingUninstall = nil } }
            )
        ) {
            Button("Remove", role: .destructive) {
                guard let pendingUninstall = model.pendingUninstall else { return }
                model.pendingUninstall = nil
                Task { await model.confirmUninstall(pendingUninstall) }
            }
            Button("Cancel", role: .cancel) {
                model.pendingUninstall = nil
            }
        } message: {
            Text("The Library copy and copies installed in other Agents will remain unchanged.")
        }
        .alert(
            "SkillDock could not complete the operation",
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
            "SkillDock could not inspect this folder",
            isPresented: Binding(
                get: { model.importPreview == nil && model.importErrorMessage != nil },
                set: { if !$0 { model.importErrorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(model.importErrorMessage ?? "")
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
        .frame(minWidth: 1100, minHeight: 700)
    }

    private var skillBrowserLayout: some View {
        @Bindable var model = model

        return NavigationSplitView {
            SidebarView(selection: $model.navigationSection)
                .navigationSplitViewColumnWidth(min: 190, ideal: 220, max: 270)
        } content: {
            SkillListView(
                records: model.filteredRecords,
                agentTargets: model.settings.agentTargets,
                acceptsImportDrop: model.navigationSection == .library,
                showsAgentFilter: model.navigationSection != .system,
                agentFilter: $model.agentFilter,
                selectionID: $model.selectionID,
                onImportDrop: { urls in
                    Task { await model.prepareImport(urls: urls) }
                }
            )
            .navigationSplitViewColumnWidth(min: 320, ideal: 380, max: 460)
        } detail: {
            SkillDetailView(model: model, record: model.selectedRecord)
        }
        .searchable(text: $model.searchQuery, prompt: "Search Skills")
        .toolbar {
            ToolbarItem {
                Menu {
                    Button {
                        Task { await model.requestImport() }
                    } label: {
                        Label("Import from Folder", systemImage: "folder")
                    }
                    Button(action: model.openRemoteImport) {
                        Label("Add from GitHub", systemImage: "shippingbox.and.arrow.backward")
                    }
                } label: {
                    Label("Add Skill", systemImage: "plus")
                }
                .help("Add Skill")
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
    }
}
