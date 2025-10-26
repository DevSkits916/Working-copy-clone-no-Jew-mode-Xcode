import SwiftUI

/// Displays the contents of a repository directory tree.
struct FileBrowserView: View {
    let files: [RepoFile]
    var statuses: [String: ChangedFile.Status] = [:]
    let onSelect: (RepoFile) -> Void

    var body: some View {
        List(files) { file in
            Button(action: { onSelect(file) }) {
                HStack {
                    Image(systemName: file.isDirectory ? "folder" : "doc.text")
                        .foregroundStyle(file.isDirectory ? .blue : .primary)
                    Text(file.name)
                        .font(.body.monospaced())
                    Spacer()
                    if let status = statuses[file.path] {
                        StatusBadge(status: status)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
}
