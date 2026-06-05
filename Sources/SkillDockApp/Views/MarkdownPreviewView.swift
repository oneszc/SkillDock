import SwiftUI

struct MarkdownPreviewView: View {
    let markdown: String

    var body: some View {
        ScrollView {
            Text(markdown)
                .font(.system(size: 14, design: .monospaced))
                .lineSpacing(4)
                .textSelection(.enabled)
                .frame(maxWidth: VisualMetrics.readableContentWidth, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(VisualMetrics.contentPadding)
        }
    }
}
