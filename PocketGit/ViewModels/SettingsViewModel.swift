import Foundation

/// Manages credential persistence and validation for the settings tab.
@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var token: String = ""
    @Published private(set) var credentials: Credentials?
    @Published var statusMessage: String = ""
    @Published var errorMessage: String?

    private let keychainManager: KeychainManager
    private let defaults = UserDefaults.standard
    private let usernameKey = "PocketGit.lastUsername"

    init(keychainManager: KeychainManager = .shared) {
        self.keychainManager = keychainManager
        if let storedUsername = defaults.string(forKey: usernameKey) {
            username = storedUsername
        }
    }

    func loadCredentials() async {
        if username.isEmpty, let storedUsername = defaults.string(forKey: usernameKey) {
            username = storedUsername
        }
        guard !username.isEmpty else { return }
        do {
            credentials = try keychainManager.loadCredentials(username: username)
            token = credentials?.token ?? ""
        } catch {
            errorMessage = "Failed to load credentials: \(error.localizedDescription)"
        }
    }

    func saveCredentials() async {
        let newCredentials = Credentials(username: username, token: token)
        do {
            try keychainManager.save(credentials: newCredentials)
            credentials = newCredentials
            statusMessage = "Credentials saved"
            defaults.set(username, forKey: usernameKey)
        } catch {
            errorMessage = "Failed to save credentials: \(error.localizedDescription)"
        }
    }
}
