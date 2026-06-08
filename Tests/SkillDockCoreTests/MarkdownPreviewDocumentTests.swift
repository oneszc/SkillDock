import XCTest
@testable import SkillDockCore

final class MarkdownPreviewDocumentTests: XCTestCase {
    func testRemovesFrontmatterAndParsesReadableBlocks() {
        let markdown = """
        ---
        name: Example
        description: Example description
        ---

        ## When to Use

        Use **this Skill** when needed.

        - First item
        - Second item

        > Important note

        ```swift
        print("Hello")
        ```
        """

        let document = MarkdownPreviewDocument(markdown: markdown)

        XCTAssertEqual(
            document.blocks,
            [
                .heading(level: 2, text: "When to Use"),
                .paragraph("Use **this Skill** when needed."),
                .unorderedList(["First item", "Second item"]),
                .quote("Important note"),
                .code(language: "swift", text: "print(\"Hello\")")
            ]
        )
    }

    func testKeepsMarkdownWithoutFrontmatterAndParsesDividerAndOrderedList() {
        let document = MarkdownPreviewDocument(
            markdown: """
            # Setup
            ---
            1. Download
            2. Install
            """
        )

        XCTAssertEqual(
            document.blocks,
            [
                .heading(level: 1, text: "Setup"),
                .divider,
                .orderedList(["Download", "Install"])
            ]
        )
    }
}
