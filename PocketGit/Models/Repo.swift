import Foundation

/// Represents a Git repository tracked by the application.
struct Repo: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var remoteURL: String
    var branch: String
    var localPath: URL

    init(id: UUID = UUID(), name: String, remoteURL: String, branch: String, localPath: URL) {
        self.id = id
        self.name = name
        self.remoteURL = remoteURL
        self.branch = branch
        self.localPath = localPath
    }
}
