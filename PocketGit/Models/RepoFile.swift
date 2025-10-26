import Foundation

/// Represents an individual file or directory within a repository.
struct RepoFile: Identifiable {
    let id = UUID()
    let name: String
    let isDirectory: Bool
    let path: String
}
