import Foundation

/// Coordinates repository persistence and cloning for the repos tab.
@MainActor
final class RepoListViewModel: ObservableObject {
    @Published private(set) var repos: [Repo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repoManager: RepoManager
    private let gitService: GitService

    init(repoManager: RepoManager = .shared, gitService: GitService = GitService()) {
        self.repoManager = repoManager
        self.gitService = gitService
    }

    func loadRepos() async {
        do {
            repos = try repoManager.loadRepos()
        } catch {
            errorMessage = "Failed to load repositories: \(error.localizedDescription)"
        }
    }

    func addRepo(remoteURL: String, branch: String?, credentials: Credentials) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let name = sanitizeName(from: remoteURL)
            let localPath = repoManager.workspaceURL(forName: name)
            try FileManager.default.createDirectory(at: localPath, withIntermediateDirectories: true)
            try await gitService.cloneRepo(remoteURL: remoteURL, branch: branch, credentials: credentials, destination: localPath)
            let repo = Repo(name: name, remoteURL: remoteURL, branch: branch ?? "main", localPath: localPath)
            repos.append(repo)
            try repoManager.saveRepos(repos)
        } catch {
            errorMessage = "Failed to add repository: \(error.localizedDescription)"
        }
    }

    func update(_ repo: Repo) async {
        guard let index = repos.firstIndex(where: { $0.id == repo.id }) else { return }
        repos[index] = repo
        do {
            try repoManager.saveRepos(repos)
        } catch {
            errorMessage = "Failed to persist repositories: \(error.localizedDescription)"
        }
    }

    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            let repo = repos[index]
            try? FileManager.default.removeItem(at: repo.localPath)
        }
        repos.remove(atOffsets: offsets)
        do {
            try repoManager.saveRepos(repos)
        } catch {
            errorMessage = "Failed to persist repositories: \(error.localizedDescription)"
        }
    }

    private func sanitizeName(from remoteURL: String) -> String {
        let components = remoteURL.split(separator: "/").last ?? Substring(UUID().uuidString)
        let name = components.replacingOccurrences(of: ".git", with: "")
        return name.isEmpty ? UUID().uuidString : name
    }
}
