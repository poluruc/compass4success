import SwiftUI

// Create a cross-platform enum for text input capitalization
public enum CompatibleTextInputCapitalization {
    case never
    case words
    case sentences
    case characters
}

extension View {
    /// Cross-platform compatible autocapitalization
    @ViewBuilder
    func compatibleAutocapitalization(_ type: CompatibleTextInputCapitalization) -> some View {
        #if os(iOS)
        if #available(iOS 16.0, *) {
            switch type {
            case .never:
                self.textInputAutocapitalization(.never)
            case .words:
                self.textInputAutocapitalization(.words)
            case .sentences:
                self.textInputAutocapitalization(.sentences)
            case .characters:
                self.textInputAutocapitalization(.characters)
            }
        } else {
            // For older iOS versions, we use the deprecated API
            switch type {
            case .never:
                self.autocapitalization(.none)
            case .words:
                self.autocapitalization(.words)
            case .sentences:
                self.autocapitalization(.sentences)
            case .characters:
                self.autocapitalization(.allCharacters)
            }
        }
        #elseif os(macOS)
        // macOS doesn't have text input autocapitalization
        self
        #else
        self
        #endif
    }
} 