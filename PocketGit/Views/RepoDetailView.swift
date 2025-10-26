import SwiftUI

/// Displays actions and file browser for a selected repository.
struct RepoDetailView: View {
    @StateObject var viewModel: RepoDetailViewModel
    @ObservedObject var changesViewModel: ChangesViewModel
    @State private var pathStack: [String] = []
    @State private var selectedFile: RepoFile?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button("Pull") {
                    Task { await viewModel.pull() }
                }
                .buttonStyle(.borderedProminent)

                Button("Push") {
                    Task { await viewModel.push() }
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)

            FileBrowserView(files: viewModel.files, statuses: viewModel.fileStatuses, onSelect: { file in
                if file.isDirectory {
                    pathStack.append(file.path)
                    viewModel.refreshFiles(at: file.path)
                } else {
                    selectedFile = file
                }
            })
            .overlay(alignment: .topLeading) {
                if !pathStack.isEmpty {
                    BreadcrumbView(pathComponents: pathStack, onNavigateUp: navigateUp)
                        .padding([.top, .leading])
                }
            }
        }
        .navigationTitle(viewModel.repo.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Refresh Files") {
                        viewModel.refreshFiles(at: pathStack.last)
                    }
                    Button("Set as Active in Changes") {
                        changesViewModel.select(repo: viewModel.repo)
                    }
                    if !pathStack.isEmpty {
                        Button("Navigate Up") {
                            navigateUp()
                        }
                    }
                } label: {
                    Label("Actions", systemImage: "ellipsis.circle")
                }
            }
        }
        .task {
            viewModel.refreshFiles(at: pathStack.last)
        }
        .alert("Error", isPresented: Binding(errorMessage: $viewModel.errorMessage)) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }

        NavigationLink(isActive: Binding(get: { selectedFile != nil }, set: { isActive in
            if !isActive { selectedFile = nil }
        })) {
            if let file = selectedFile {
                FileEditorView(viewModel: FileEditorViewModel(fileURL: viewModel.repo.localPath.appendingPathComponent(file.path)), filePath: file.path)
            } else {
                EmptyView()
            }
        } label: {
            EmptyView()
        }
    }

    private func navigateUp() {
        _ = pathStack.popLast()
        viewModel.refreshFiles(at: pathStack.last)
    }
}
