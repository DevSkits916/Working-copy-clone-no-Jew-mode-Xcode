import Foundation

/// Represents saved authentication credentials for Git remotes.
struct Credentials: Codable, Equatable {
    var username: String
    var token: String
}
