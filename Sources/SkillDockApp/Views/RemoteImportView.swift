import SkillDockCore
import SwiftUI

struct RemoteImportView: View {
    @Bindable var appModel: AppModel

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            content
            Divider()
            footer
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Image(systemName: "shippingbox.and.arrow.backward")
                .font(.title)
                .foregroundStyle(Color.accentColor)
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 4) {
                Text("Add from GitHub")
                    .font(.title2.weight(.semibold))
                Text(headerDescription)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(VisualMetrics.compactContentPadding)
    }

    @ViewBuilder
    private var content: some View {
        switch appModel.remoteImport.step {
        case .link:
            linkStep
        case .skills:
            skillsStep
        case .result:
            resultStep
        }
    }

    private var linkStep: some View {
        Form {
            Section("Public GitHub Repository") {
                TextField(
                    "https://github.com/owner/repository",
                    text: $appModel.remoteImport.link
                )
                Text("Repository links and links to a Skill folder are supported.")
                    .foregroundStyle(.secondary)
            }
            Section("Download Method") {
                Picker("Method", selection: $appModel.remoteImport.preference) {
                    Text("Automatic").tag(RemoteAcquisitionPreference.automatic)
                    Text("Git Clone").tag(RemoteAcquisitionPreference.gitClone)
                    Text("ZIP").tag(RemoteAcquisitionPreference.zip)
                }
                .pickerStyle(.segmented)
                Text(methodDescription)
                    .foregroundStyle(.secondary)
            }
            if let error = appModel.remoteImport.errorMessage {
                Section {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }
            }
        }
        .formStyle(.grouped)
    }

    private var skillsStep: some View {
        List {
            if let repository = appModel.remoteImport.repository {
                Section {
                    LabeledContent("Repository", value: repository.reference.repositoryURL.absoluteString)
                    LabeledContent("Downloaded with", value: methodName(repository.method))
                    LabeledContent("Skills found", value: "\(appModel.remoteImport.candidates.count)")
                }
            }
            Section("Choose Skills") {
                ForEach($appModel.remoteImport.candidates) { $candidate in
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: $candidate.isSelected) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(candidate.name)
                                    .font(.body.weight(.medium))
                                Text(candidate.repositoryRelativePath)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        HStack {
                            if candidate.hasScripts {
                                Label("Contains scripts", systemImage: "exclamationmark.triangle")
                                    .foregroundStyle(.orange)
                            }
                            if candidate.hasConflict {
                                Label("Already in Library", systemImage: "exclamationmark.circle")
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(candidate.fileCount) files")
                                .foregroundStyle(.secondary)
                        }
                        .font(.callout)
                        if candidate.hasConflict && candidate.isSelected {
                            Picker("Conflict", selection: $candidate.strategy) {
                                Text("Skip").tag(ConflictStrategy.skip)
                                Text("Replace").tag(ConflictStrategy.overwrite)
                                Text("Rename").tag(ConflictStrategy.rename)
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .listStyle(.inset)
    }

    private var resultStep: some View {
        ContentUnavailableView {
            Label("Import Complete", systemImage: "checkmark.circle")
        } description: {
            if let result = appModel.remoteImport.result {
                Text(
                    "\(result.copied.count) imported, \(result.skipped.count) skipped, \(result.failures.count) failed."
                )
            }
        }
    }

    private var footer: some View {
        HStack {
            if appModel.remoteImport.isWorking {
                ProgressView()
                    .controlSize(.small)
            }
            Spacer()
            Button(appModel.remoteImport.step == .result ? "Close" : "Cancel") {
                appModel.closeRemoteImport()
            }
            if appModel.remoteImport.step == .link {
                Button("Find Skills") {
                    Task { await appModel.remoteImport.inspect(libraryPath: appModel.settings.libraryPath) }
                }
                .buttonStyle(.borderedProminent)
                .disabled(appModel.remoteImport.link.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } else if appModel.remoteImport.step == .skills {
                Button("Import Selected") {
                    Task { await appModel.confirmRemoteImport() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(appModel.remoteImport.selectedCount == 0)
            }
        }
        .padding(VisualMetrics.compactContentPadding)
        .disabled(appModel.remoteImport.isWorking)
    }

    private var headerDescription: String {
        switch appModel.remoteImport.step {
        case .link: "Paste a public repository or Skill folder link."
        case .skills: "Choose which Skills to add to your Library."
        case .result: "Skills were added only to your main Library."
        }
    }

    private var methodDescription: String {
        switch appModel.remoteImport.preference {
        case .automatic: "Uses Git Clone first and falls back to ZIP when needed."
        case .gitClone: "Keeps a managed repository so updates can be checked later."
        case .zip: "Downloads a temporary archive without keeping a managed repository."
        }
    }

    private func methodName(_ method: RemoteAcquisitionMethod) -> String {
        switch method {
        case .gitClone: "Git Clone"
        case .zip: "ZIP"
        }
    }
}
