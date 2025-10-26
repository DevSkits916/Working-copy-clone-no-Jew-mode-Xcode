# PocketGit

PocketGit is a SwiftUI-based iOS application that provides an on-device Git client experience inspired by Working Copy. The app structures repository management, change tracking, and credential handling into a modern SwiftUI architecture ready for further enhancement with low-level Git integrations.

## Project Structure

- `PocketGitApp.swift` – SwiftUI app entry point configuring the main tab layout.
- `Models/` – Data models for repositories, files, credentials, and Git status entries.
- `Services/` – Persistence and security services plus the `GitService` abstraction for Git operations.
- `ViewModels/` – ObservableObject classes powering each tab and view flow.
- `Views/` – SwiftUI views implementing repository browsing, change review, settings, and editing UI.
- `Utilities/` – Shared SwiftUI helper extensions.

## Implemented Features

- Repository list with add/delete support and JSON-backed persistence for repo metadata.
- Credentials form backed by Keychain storage utilities for username/token pairs.
- Git service abstraction encapsulating clone, pull, push, status, staging, and commit operations (Process-based stubbed implementation).
- File browser and editor scaffolding with monospaced text editing, binary detection, and save actions.
- Changes tab showing modified files, commit message entry, and a commit/push button.

## Work Remaining / Integration Notes

- **Git execution on iOS:** The current `GitService` uses `Process` to run `git` binaries, which is not available on iOS. Replace with a libgit2 integration or custom C module that exposes equivalent operations. This will require bridging headers and potential entitlements for executing native code.
- **Authentication:** Hook HTTPS credential usage into the chosen Git backend. For libgit2, provide callbacks for username/token authentication when cloning, pulling, or pushing.
- **Navigation to Editor:** Implement a navigation coordinator or `.navigationDestination` modifiers to push `FileEditorView` from `RepoDetailView` when selecting files.
- **Branch management:** Expand UI to allow switching branches and handling default branch detection instead of assuming `main`.
- **Binary handling:** Provide read-only previews or diffing for binary files.
- **Error reporting:** Surface detailed Git errors and integrate logging/analytics as needed.

## Security Notes

- Credentials are persisted in the iOS Keychain via `KeychainManager`, leveraging `kSecClassGenericPassword` secure storage.
- The app never hardcodes tokens and expects the user to provide/update credentials from the Settings tab.
- Future Git backend integrations should avoid logging sensitive information and ensure tokens are transmitted only over secure HTTPS connections.

