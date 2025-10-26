import SwiftUI

/// Allows the user to manage authentication credentials.
struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("Credentials") {
                TextField("Username", text: $viewModel.username)
                SecureField("Personal Access Token", text: $viewModel.token)
                Button("Save") {
                    Task { await viewModel.saveCredentials() }
                }
            }

            if !viewModel.statusMessage.isEmpty {
                Section {
                    Text(viewModel.statusMessage)
                        .foregroundStyle(.green)
                }
            }
        }
        .navigationTitle("Settings")
        .alert("Error", isPresented: Binding(errorMessage: $viewModel.errorMessage)) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
