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
            let nativeType: TextInputAutocapitalization
            switch type {
            case .never:
                nativeType = .never
            case .words:
                nativeType = .words
            case .sentences:
                nativeType = .sentences
            case .characters:
                nativeType = .characters
            }
            self.textInputAutocapitalization(nativeType)
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