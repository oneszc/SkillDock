import SwiftUI

struct FilesView: View {
    let paths: [String]

    var body: some View {
        List(paths, id: \.self) { path in
            Label(path, systemImage: path.contains(".") ? "doc" : "folder")
                .font(.body)
                .textSelection(.enabled)
                .listRowInsets(
                    EdgeInsets(
                        top: 4,
                        leading: 0,
                        bottom: 4,
                        trailing: 0
                    )
                )
        }
    }
}
