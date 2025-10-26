import SwiftUI

/// Presents staged and unstaged changes and commit controls.
struct ChangesView: View {
    @ObservedObject var viewModel: ChangesViewModel

    var body: some View {
        VStack(alignment: .leading) {
            if let repo = viewModel.selectedRepo {
                Text("Active Repo: \(repo.name)")
                    .font(.headline)
                    .padding(.horizontal)
            }

            List {
                Section("Changed Files") {
                    ForEach(viewModel.changedFiles) { file in
                        Button(action: { Task { await viewModel.toggleStaging(for: file) } }) {
                            HStack {
                                Image(systemName: file.isStaged ? "checkmark.square" : "square")
                                VStack(alignment: .leading) {
                                    Text(file.filename)
                                    Text(file.status.rawValue.capitalized)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section("Commit") {
                    TextField("Commit message", text: $viewModel.commitMessage, axis: .vertical)
                    Button("Commit & Push") {
                        Task { await viewModel.commitAndPush() }
                    }
                    .disabled(viewModel.commitMessage.isEmpty)
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Changes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Refresh") {
                    Task { await viewModel.refreshStatus() }
                }
            }
        }
        .alert("Error", isPresented: Binding(errorMessage: $viewModel.errorMessage)) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .task {
            await viewModel.refreshStatus()
        }
    }
}
