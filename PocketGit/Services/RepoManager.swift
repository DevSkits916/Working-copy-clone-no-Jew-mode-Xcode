import Foundation

/// Persists and retrieves repository metadata stored locally on disk.
final class RepoManager {
    static let shared = RepoManager()

    private let fileManager = FileManager.default
    private let storageURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private init() {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        storageURL = documents.appendingPathComponent("Repos.json")
    }

    func loadRepos() throws -> [Repo] {
        guard fileManager.fileExists(atPath: storageURL.path) else {
            return []
        }
        let data = try Data(contentsOf: storageURL)
        return try decoder.decode([Repo].self, from: data)
    }

    func saveRepos(_ repos: [Repo]) throws {
        let data = try encoder.encode(repos)
        try data.write(to: storageURL, options: [.atomic])
    }

    func workspaceURL(for repo: Repo) -> URL {
        workspaceURL(forName: repo.name)
    }

    func workspaceURL(forName name: String) -> URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return documents.appendingPathComponent(name, isDirectory: true)
    }
}
