import SkillDockCore
import SwiftUI

struct MarkdownPreviewView: View {
    let markdown: String

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(Array(document.blocks.enumerated()), id: \.offset) { _, block in
                    blockView(block)
                }
            }
                .font(.body)
                .lineSpacing(5)
                .textSelection(.enabled)
                .frame(maxWidth: VisualMetrics.readableContentWidth, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(VisualMetrics.contentPadding)
        }
    }

    private var document: MarkdownPreviewDocument {
        MarkdownPreviewDocument(markdown: markdown)
    }

    @ViewBuilder
    private func blockView(_ block: MarkdownPreviewDocument.Block) -> some View {
        switch block {
        case let .heading(level, text):
            inlineText(text)
                .font(headingFont(level))
                .padding(.top, level == 1 ? 4 : 10)
        case let .paragraph(text):
            inlineText(text)
        case let .unorderedList(items):
            VStack(alignment: .leading, spacing: 9) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("•")
                        inlineText(item)
                    }
                }
            }
        case let .orderedList(items):
            VStack(alignment: .leading, spacing: 9) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("\(index + 1).")
                            .foregroundStyle(.secondary)
                            .frame(minWidth: 22, alignment: .trailing)
                        inlineText(item)
                    }
                }
            }
        case let .quote(text):
            HStack(alignment: .top, spacing: 12) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(.tertiary)
                    .frame(width: 3)
                inlineText(text)
                    .foregroundStyle(.secondary)
            }
        case let .code(language, text):
            VStack(alignment: .leading, spacing: 10) {
                if let language {
                    Text(language.uppercased())
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                Text(text)
                    .font(.system(.body, design: .monospaced))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
        case .divider:
            Divider()
        }
    }

    private func inlineText(_ markdown: String) -> Text {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        guard let attributed = try? AttributedString(markdown: markdown, options: options) else {
            return Text(markdown)
        }
        return Text(attributed)
    }

    private func headingFont(_ level: Int) -> Font {
        switch level {
        case 1: .title.weight(.semibold)
        case 2: .title2.weight(.semibold)
        case 3: .title3.weight(.semibold)
        default: .headline
        }
    }
}
