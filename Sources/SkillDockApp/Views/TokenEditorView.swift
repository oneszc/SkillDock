import SwiftUI

struct TokenEditorView: View {
    let title: String
    let suggestions: [String]
    @Binding var values: [String]
    @State private var input = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 90), spacing: 6)],
                alignment: .leading,
                spacing: 6
            ) {
                ForEach(values, id: \.self) { value in
                    Button {
                        values.removeAll { $0 == value }
                    } label: {
                        Label(value, systemImage: "xmark.circle.fill")
                            .lineLimit(1)
                    }
                    .buttonStyle(.bordered)
                    .help("Remove \(value)")
                }
            }

            HStack {
                TextField("Add \(title.lowercased())", text: $input)
                    .onSubmit(addInput)
                Menu {
                    if availableSuggestions.isEmpty {
                        Text("No suggestions")
                    } else {
                        ForEach(availableSuggestions, id: \.self) { suggestion in
                            Button(suggestion) { add(suggestion) }
                        }
                    }
                } label: {
                    Label("Suggestions", systemImage: "plus.circle")
                }
            }
        }
    }

    private var availableSuggestions: [String] {
        suggestions.filter { suggestion in
            !values.contains {
                $0.compare(
                    suggestion,
                    options: [.caseInsensitive, .diacriticInsensitive]
                ) == .orderedSame
            }
        }
    }

    private func addInput() {
        add(input)
        input = ""
    }

    private func add(_ candidate: String) {
        let value = candidate.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        guard !values.contains(where: {
            $0.compare(
                value,
                options: [.caseInsensitive, .diacriticInsensitive]
            ) == .orderedSame
        }) else { return }
        values.append(value)
    }
}
