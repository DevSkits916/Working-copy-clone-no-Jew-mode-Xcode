import Foundation

/// Tracks modified files and coordinates commit/push workflows.
@MainActor
final class ChangesViewModel: ObservableObject {
    @Published private(set) var changedFiles: [ChangedFile] = []
    @Published var commitMessage: String = ""
    @Published var statusMessage: String = ""
    @Published var errorMessage: String?
    @Published private(set) var selectedRepo: Repo?

    private let gitService = GitService()
    private weak var repoListViewModel: RepoListViewModel?
    private weak var settingsViewModel: SettingsViewModel?

    func bind(repoListViewModel: RepoListViewModel) {
        self.repoListViewModel = repoListViewModel
        if selectedRepo == nil {
            selectedRepo = repoListViewModel.repos.first
        }
        Task { await refreshStatus() }
    }

    func bind(settingsViewModel: SettingsViewModel) {
        self.settingsViewModel = settingsViewModel
    }

    func select(repo: Repo) {
        selectedRepo = repo
        Task { await refreshStatus() }
    }

    func refreshStatus() async {
        guard let repo = selectedRepo else { return }
        do {
            changedFiles = try await gitService.getStatus(in: repo.localPath)
        } catch {
            errorMessage = "Failed to fetch status: \(error.localizedDescription)"
        }
    }

    func toggleStaging(for file: ChangedFile) async {
        guard let repo = selectedRepo else { return }
        do {
            if file.isStaged {
                try await gitService.unstageFile(at: file.path, in: repo.localPath)
            } else {
                try await gitService.stageFile(at: file.path, in: repo.localPath)
            }
            await refreshStatus()
        } catch {
            errorMessage = "Failed to stage file: \(error.localizedDescription)"
        }
    }

    func commitAndPush() async {
        guard let repo = selectedRepo else { return }
        guard let credentials = settingsViewModel?.credentials, !credentials.username.isEmpty else {
            errorMessage = "Missing credentials. Add them in Settings."
            return
        }

        do {
            try await gitService.commit(message: commitMessage, author: credentials.username, in: repo.localPath)
            try await gitService.push(in: repo.localPath)
            commitMessage = ""
            statusMessage = "Commit pushed to remote"
            await refreshStatus()
        } catch {
            errorMessage = "Commit or push failed: \(error.localizedDescription)"
        }
    }
}
