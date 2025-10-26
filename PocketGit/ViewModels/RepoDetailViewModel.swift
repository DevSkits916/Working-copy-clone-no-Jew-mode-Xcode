import Foundation

/// Manages file browsing and sync actions for a single repository.
@MainActor
final class RepoDetailViewModel: ObservableObject {
    @Published private(set) var repo: Repo
    @Published private(set) var files: [RepoFile] = []
    @Published private(set) var fileStatuses: [String: ChangedFile.Status] = [:]
    @Published var statusMessage: String = ""
    @Published var errorMessage: String?

    private let gitService: GitService

    init(repo: Repo, gitService: GitService = GitService()) {
        self.repo = repo
        self.gitService = gitService
    }

    func refreshFiles(at relativePath: String? = nil) {
        let path = relativePath ?? ""
        let directoryURL = repo.localPath.appendingPathComponent(path)
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
            files = contents.map { url in
                let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                return RepoFile(name: url.lastPathComponent, isDirectory: isDirectory, path: url.path.replacingOccurrences(of: repo.localPath.path + "/", with: ""))
            }.sorted { lhs, rhs in
                if lhs.isDirectory != rhs.isDirectory {
                    return lhs.isDirectory
                }
                return lhs.name.lowercased() < rhs.name.lowercased()
            }
            Task { await refreshStatus() }
        } catch {
            errorMessage = "Unable to read repository contents: \(error.localizedDescription)"
        }
    }

    func pull() async {
        do {
            try await gitService.pull(in: repo.localPath)
            statusMessage = "Pulled latest changes"
            refreshFiles()
        } catch {
            errorMessage = "Pull failed: \(error.localizedDescription)"
        }
    }

    func push() async {
        do {
            try await gitService.push(in: repo.localPath)
            statusMessage = "Pushed to remote"
        } catch {
            errorMessage = "Push failed: \(error.localizedDescription)"
        }
    }

    func setRepo(_ repo: Repo) {
        self.repo = repo
        refreshFiles()
    }

    func refreshStatus() async {
        do {
            let status = try await gitService.getStatus(in: repo.localPath)
            fileStatuses = Dictionary(uniqueKeysWithValues: status.map { ($0.path, $0.status) })
        } catch {
            errorMessage = "Failed to read status: \(error.localizedDescription)"
        }
    }
}
