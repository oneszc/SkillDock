import SkillDockCore
import SwiftUI

struct RemoteUpdatePreviewView: View {
    @Bindable var model: AppModel
    let update: RemoteSkillUpdate

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    statusBlock
                    changeSection("Added", files: update.addedFiles, systemImage: "plus.circle")
                    changeSection("Modified", files: update.modifiedFiles, systemImage: "pencil.circle")
                    changeSection("Removed", files: update.removedFiles, systemImage: "minus.circle")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
            }
            Divider()
            footer
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            Image(systemName: headerIcon)
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(headerColor)
            VStack(alignment: .leading, spacing: 5) {
                Text(headerTitle)
                    .font(.title2.weight(.semibold))
                Text("\(update.source.owner)/\(update.source.repository)")
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
            Spacer()
        }
        .padding(24)
    }

    private var statusBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(statusTitle, systemImage: headerIcon)
                .font(.headline)
                .foregroundStyle(headerColor)
            Text(statusDescription)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 12) {
                versionLabel("Current", value: update.currentCommit)
                versionLabel("Remote", value: update.remoteCommit)
            }
        }
    }

    private func versionLabel(_ title: String, value: String) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .foregroundStyle(.secondary)
            Text(value)
                .monospaced()
                .lineLimit(1)
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.quaternary, in: Capsule())
    }

    private func changeSection(
        _ title: String,
        files: [String],
        systemImage: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("\(title) \(files.count)", systemImage: systemImage)
                .font(.headline)
            if files.isEmpty {
                Text("No files.")
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(files, id: \.self) { file in
                        Text(file)
                            .monospaced()
                            .lineLimit(1)
                    }
                }
                .font(.callout)
            }
        }
    }

    private var footer: some View {
        HStack {
            Spacer()
            Button("Cancel") {
                model.isRemoteUpdatePreviewPresented = false
            }
            Button(update.status == .localModified ? "Review Required" : "Update") {
                Task { await model.confirmRemoteReplacement() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(update.status != .updateAvailable)
        }
        .padding(20)
    }

    private var headerTitle: String {
        switch update.status {
        case .upToDate: "Skill is up to date"
        case .updateAvailable: "Update available"
        case .localModified: "Local changes detected"
        }
    }

    private var statusTitle: String { headerTitle }

    private var statusDescription: String {
        switch update.status {
        case .upToDate:
            "The Library copy already matches the latest remote Skill."
        case .updateAvailable:
            "Remote files changed. Review the file list, then update manually if it looks right."
        case .localModified:
            "This Skill has local edits after import. SkillDock will not replace it automatically."
        }
    }

    private var headerIcon: String {
        switch update.status {
        case .upToDate: "checkmark.circle.fill"
        case .updateAvailable: "arrow.down.circle.fill"
        case .localModified: "exclamationmark.triangle.fill"
        }
    }

    private var headerColor: Color {
        switch update.status {
        case .upToDate: .green
        case .updateAvailable: .blue
        case .localModified: .orange
        }
    }
}
