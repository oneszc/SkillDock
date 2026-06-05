import SwiftUI

struct MarkdownPreviewView: View {
    let markdown: String

    var body: some View {
        ScrollView {
            Text(markdown)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
        }
    }
}
