import Foundation
import Security

/// Handles secure storage of credentials in the system Keychain.
final class KeychainManager {
    static let shared = KeychainManager()

    private init() {}

    func save(credentials: Credentials) throws {
        let account = credentials.username
        let service = "com.pocketgit.credentials"
        let accessTokenData = credentials.token.data(using: .utf8) ?? Data()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: accessTokenData
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query.merging(attributes) { $1 } as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    func loadCredentials(username: String) throws -> Credentials? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecAttrService as String: "com.pocketgit.credentials",
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status != errSecItemNotFound else {
            return nil
        }

        guard status == errSecSuccess, let data = item as? Data, let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.unhandledError(status: status)
        }

        return Credentials(username: username, token: token)
    }

    enum KeychainError: Error {
        case unhandledError(status: OSStatus)
    }
}
