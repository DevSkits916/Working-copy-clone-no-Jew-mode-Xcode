import SwiftUI

/// Lists all repositories and handles navigation into details.
struct RepoListView: View {
    @ObservedObject var viewModel: RepoListViewModel
    @ObservedObject var changesViewModel: ChangesViewModel
    @State private var isPresentingAddRepo = false

    var body: some View {
        List {
            ForEach(viewModel.repos) { repo in
                NavigationLink(destination: RepoDetailView(viewModel: RepoDetailViewModel(repo: repo), changesViewModel: changesViewModel)) {
                    VStack(alignment: .leading) {
                        Text(repo.name)
                            .font(.headline)
                        Text(repo.remoteURL)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete(perform: viewModel.delete)
        }
        .overlay {
            if viewModel.repos.isEmpty {
                ContentUnavailableView("No repositories", systemImage: "folder.badge.questionmark", description: Text("Add a repository to get started."))
            }
        }
        .navigationTitle("Repositories")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isPresentingAddRepo.toggle() }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Repository")
            }
        }
        .refreshable {
            await viewModel.loadRepos()
        }
        .task {
            await viewModel.loadRepos()
        }
        .alert("Error", isPresented: Binding(errorMessage: $viewModel.errorMessage)) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $isPresentingAddRepo) {
            NavigationStack {
                AddRepoView(viewModel: viewModel, isPresented: $isPresentingAddRepo)
            }
        }
    }
}
