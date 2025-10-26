import SwiftUI

/// Presents an editor for text-based repository files.
struct FileEditorView: View {
    @StateObject var viewModel: FileEditorViewModel
    let filePath: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(filePath)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            if viewModel.isBinary {
                Text(viewModel.content)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                TextEditor(text: $viewModel.content)
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal)
            }

            HStack {
                Spacer()
                Button("Save") {
                    viewModel.save()
                }
                .disabled(viewModel.isBinary)
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Editor")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.load() }
        .alert("Error", isPresented: Binding(errorMessage: $viewModel.errorMessage)) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
