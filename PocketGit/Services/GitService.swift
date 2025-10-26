import Foundation

/// Provides high-level Git operations for repositories using underlying command execution or libgit2 bridging.
final class GitService {
    private let fileManager = FileManager.default
    private let queue = DispatchQueue(label: "com.pocketgit.gitservice", qos: .userInitiated)

    /// Clones a repository to a local path.
    func cloneRepo(remoteURL: String, branch: String?, credentials: Credentials, destination: URL) async throws {
        // TODO: Inject HTTPS credentials into libgit2 callbacks or credential helpers.
        // With a Process-based implementation this would require configuring GIT_ASKPASS or using credential helpers.
        try await runGitCommand(["clone", remoteURL, destination.path])
        if let branch = branch, !branch.isEmpty {
            try await runGitCommand(["checkout", branch], workingDirectory: destination)
        }
    }

    /// Pulls the latest changes for the repository.
    func pull(in repositoryURL: URL) async throws {
        // TODO: Supply credentials for private remotes when the libgit2 backend is in place.
        try await runGitCommand(["pull", "origin"], workingDirectory: repositoryURL)
    }

    /// Pushes local commits to the remote repository.
    func push(in repositoryURL: URL) async throws {
        // TODO: Provide credential callbacks for pushes when replacing Process with libgit2.
        try await runGitCommand(["push", "origin"], workingDirectory: repositoryURL)
    }

    /// Returns the status for files in the repository.
    func getStatus(in repositoryURL: URL) async throws -> [ChangedFile] {
        let output = try await runGitCommand(["status", "--porcelain"], workingDirectory: repositoryURL)
        return parseStatus(output: output)
    }

    /// Stages a specific file.
    func stageFile(at path: String, in repositoryURL: URL) async throws {
        try await runGitCommand(["add", path], workingDirectory: repositoryURL)
    }

    /// Unstages a specific file.
    func unstageFile(at path: String, in repositoryURL: URL) async throws {
        try await runGitCommand(["reset", "HEAD", path], workingDirectory: repositoryURL)
    }

    /// Commits the staged changes with the provided message and author name.
    func commit(message: String, author: String, in repositoryURL: URL) async throws {
        let env = [
            "GIT_AUTHOR_NAME": author,
            "GIT_COMMITTER_NAME": author
        ]
        _ = try await runGitCommand(["commit", "-m", message], workingDirectory: repositoryURL, environment: env)
    }

    // MARK: - Private helpers

    private func runGitCommand(_ arguments: [String], workingDirectory: URL? = nil, environment: [String: String] = [:]) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                // TODO: Replace Process usage with libgit2 or a custom static library compiled for iOS.
                // iOS does not allow spawning arbitrary processes, so this Process-based approach only works in simulators/macOS.
                // Integrate libgit2 via Swift Package Manager or a bridging header and implement equivalents for these commands.
                // Ensure the app declares the appropriate outbound network entitlement and Info.plist ATS exceptions if private Git servers are used.
                let process = Process()
                process.launchPath = "/usr/bin/env"
                process.arguments = ["git"] + arguments
                if let workingDirectory = workingDirectory {
                    process.currentDirectoryURL = workingDirectory
                }
                process.environment = environment.merging(ProcessInfo.processInfo.environment) { current, _ in current }

                let outputPipe = Pipe()
                process.standardOutput = outputPipe
                process.standardError = outputPipe

                do {
                    try process.run()
                } catch {
                    continuation.resume(throwing: error)
                    return
                }

                process.waitUntilExit()

                let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""

                guard process.terminationStatus == 0 else {
                    continuation.resume(throwing: GitServiceError.commandFailed(output: output))
                    return
                }

                continuation.resume(returning: output)
            }
        }
    }

    private func parseStatus(output: String) -> [ChangedFile] {
        return output.split(separator: "\n").compactMap { line in
            guard line.count >= 3 else { return nil }
            let stagedCode = line[line.startIndex]
            let workTreeIndex = line.index(after: line.startIndex)
            let workTreeCode = line[workTreeIndex]
            let filePath = String(line.dropFirst(3))
            let status = statusFrom(code: workTreeCode == " " ? stagedCode : workTreeCode)
            let filename = URL(fileURLWithPath: filePath).lastPathComponent
            let isStaged = stagedCode != " "
            return ChangedFile(filename: filename, path: filePath, status: status, isStaged: isStaged)
        }
    }

    private func statusFrom(code: Character) -> ChangedFile.Status {
        switch code {
        case "M": return .modified
        case "A": return .added
        case "D": return .deleted
        case "R": return .renamed
        case "?": return .untracked
        case "U": return .conflicted
        default: return .modified
        }
    }

    enum GitServiceError: Error {
        case commandFailed(output: String)
    }
}
