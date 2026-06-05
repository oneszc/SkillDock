import SkillDockCore
import SwiftUI

struct ImportPreviewView: View {
    @Bindable var model: AppModel
    @State private var confirmsOverwrite = false

    var body: some View {
        if let preview = model.importPreview {
            VStack(spacing: 0) {
                header(preview)
                Divider()
                Form {
                    if preview.hasScripts {
                        Section {
                            Label(
                                "This Skill contains scripts. Review them before importing.",
                                systemImage: "exclamationmark.triangle.fill"
                            )
                            .foregroundStyle(.orange)
                        }
                    }

                    Section("Import") {
                        LabeledContent("Source", value: preview.sourceURL.path)
                        LabeledContent("Files", value: "\(preview.fileCount)")
                        if preview.hasConflict {
                            Label(
                                "A Skill with this folder name already exists.",
                                systemImage: "exclamationmark.circle"
                            )
                            Picker(
                                "Conflict strategy",
                                selection: Binding(
                                    get: { model.importPreview?.strategy ?? .skip },
                                    set: { strategy in
                                        model.updateImportStrategy(strategy)
                                    }
                                )
                            ) {
                                Text("Skip").tag(ConflictStrategy.skip)
                                Text("Replace").tag(ConflictStrategy.overwrite)
                                Text("Rename").tag(ConflictStrategy.rename)
                            }
                        }
                    }

                    Section("Files") {
                        ForEach(preview.relativePaths, id: \.self) { path in
                            Label(path, systemImage: path.contains(".") ? "doc" : "folder")
                        }
                    }
                }
                .formStyle(.grouped)

                Divider()
                HStack {
                    if let message = model.importErrorMessage {
                        Label(message, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                            .lineLimit(2)
                    }
                    Spacer()
                    Button("Cancel") {
                        model.importPreview = nil
                    }
                    Button("Import") {
                        if model.importPreview?.strategy == .overwrite {
                            confirmsOverwrite = true
                        } else {
                            Task { await model.confirmImport() }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(16)
            }
            .confirmationDialog(
                "Replace the existing Skill?",
                isPresented: $confirmsOverwrite
            ) {
                Button("Replace", role: .destructive) {
                    Task { await model.confirmImport() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("The existing folder will be replaced only after you confirm.")
            }
        }
    }

    private func header(_ preview: ImportPreview) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "square.and.arrow.down")
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 34, height: 34)
            VStack(alignment: .leading, spacing: 3) {
                Text(preview.name)
                    .font(.title3.weight(.semibold))
                Text(preview.description ?? "Review this Skill before importing.")
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(18)
    }
}
