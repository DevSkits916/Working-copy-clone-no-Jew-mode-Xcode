import SwiftUI

/// Renders a breadcrumb path for repository navigation.
struct BreadcrumbView: View {
    let pathComponents: [String]
    let onNavigateUp: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "folder")
            Text(pathComponents.last ?? "")
                .font(.caption)
            Button(action: onNavigateUp) {
                Image(systemName: "chevron.up")
            }
            .buttonStyle(.plain)
        }
        .padding(6)
        .background(.ultraThinMaterial, in: Capsule())
    }
}
