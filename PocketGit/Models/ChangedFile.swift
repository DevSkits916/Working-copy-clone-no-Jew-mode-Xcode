import Foundation

/// Represents the status of a file reported by Git.
struct ChangedFile: Identifiable, Hashable {
    enum Status: String, Codable {
        case modified
        case added
        case deleted
        case renamed
        case untracked
        case conflicted
    }

    let id = UUID()
    let filename: String
    let path: String
    let status: Status
    var isStaged: Bool = false
}
