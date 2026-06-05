import SwiftUI

struct FilesView: View {
    let paths: [String]

    var body: some View {
        List(paths, id: \.self) { path in
            Label(path, systemImage: path.contains(".") ? "doc" : "folder")
                .font(.body)
                .padding(.vertical, 4)
                .textSelection(.enabled)
        }
    }
}
