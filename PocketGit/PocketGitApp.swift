import SwiftUI

/// Entry point of the PocketGit application configuring the main tab structure.
@main
struct PocketGitApp: App {
    @StateObject private var repoListViewModel = RepoListViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var changesViewModel = ChangesViewModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack {
                    RepoListView(viewModel: repoListViewModel, changesViewModel: changesViewModel)
                }
                .tabItem {
                    Label("Repos", systemImage: "folder")
                }

                NavigationStack {
                    ChangesView(viewModel: changesViewModel)
                }
                .tabItem {
                    Label("Changes", systemImage: "square.and.pencil")
                }

                NavigationStack {
                    SettingsView(viewModel: settingsViewModel)
                }
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
            }
            .task {
                await settingsViewModel.loadCredentials()
                await repoListViewModel.loadRepos()
                changesViewModel.bind(repoListViewModel: repoListViewModel)
                changesViewModel.bind(settingsViewModel: settingsViewModel)
            }
        }
    }
}
