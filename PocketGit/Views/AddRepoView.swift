import SwiftUI

/// Presents a form for adding a new repository to the app.
struct AddRepoView: View {
    @ObservedObject var viewModel: RepoListViewModel
    @Binding var isPresented: Bool
    @State private var remoteURL: String = ""
    @State private var branch: String = "main"
    @State private var username: String = ""
    @State private var token: String = ""

    var body: some View {
        Form {
            Section("Repository") {
                TextField("Remote URL", text: $remoteURL)
                    .textContentType(.URL)
                    .autocapitalization(.none)
                TextField("Branch (optional)", text: $branch)
                    .textContentType(.none)
                    .autocapitalization(.none)
            }

            Section("Credentials") {
                TextField("Username", text: $username)
                    .textContentType(.username)
                SecureField("Access Token", text: $token)
            }
        }
        .navigationTitle("Add Repository")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { isPresented = false }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    let credentials = Credentials(username: username, token: token)
                    Task {
                        await viewModel.addRepo(remoteURL: remoteURL, branch: branch.isEmpty ? nil : branch, credentials: credentials)
                        isPresented = false
                    }
                }
                .disabled(remoteURL.isEmpty || username.isEmpty || token.isEmpty)
            }
        }
    }
}
