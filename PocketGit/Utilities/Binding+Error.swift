import SwiftUI

/// Convenience binding to present alerts based on optional error messages.
extension Binding where Value == Bool {
    init(errorMessage: Binding<String?>) {
        self.init(get: { errorMessage.wrappedValue != nil }, set: { newValue in
            if !newValue {
                errorMessage.wrappedValue = nil
            }
        })
    }
}
