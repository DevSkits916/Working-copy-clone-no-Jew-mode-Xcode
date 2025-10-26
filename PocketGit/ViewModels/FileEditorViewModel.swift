import Foundation

/// Loads and saves text content for files being edited.
@MainActor
final class FileEditorViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var isBinary: Bool = false
    @Published var errorMessage: String?

    private let fileURL: URL

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            isBinary = data.contains { $0 == 0 }
            guard !isBinary else {
                content = "Binary files are not supported for editing."
                return
            }
            if let string = String(data: data, encoding: .utf8) {
                content = string
            } else {
                isBinary = true
                content = "Unsupported encoding."
            }
        } catch {
            errorMessage = "Failed to open file: \(error.localizedDescription)"
        }
    }

    func save() {
        guard !isBinary else { return }
        do {
            guard let data = content.data(using: .utf8) else {
                errorMessage = "Unsupported encoding for saving."
                return
            }
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            errorMessage = "Unable to save file: \(error.localizedDescription)"
        }
    }
}
