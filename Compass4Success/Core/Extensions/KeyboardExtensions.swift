import SwiftUI

// Create cross-platform keyboard type enum
public enum CompatibleKeyboardType {
    case `default`
    case emailAddress
    case numberPad
    case decimalPad
    case phonePad
    case URL
    case namePhonePad
}

// Extend View with cross-platform keyboard type modifiers
extension View {
    /// Apply keyboard type in a cross-platform way
    @ViewBuilder
    func compatibleKeyboardType(_ type: CompatibleKeyboardType) -> some View {
        #if os(iOS)
        // iOS supports keyboardType
        let uiKeyboardType: UIKeyboardType
        switch type {
        case .default:
            uiKeyboardType = .default
        case .emailAddress:
            uiKeyboardType = .emailAddress
        case .numberPad:
            uiKeyboardType = .numberPad
        case .decimalPad:
            uiKeyboardType = .decimalPad
        case .phonePad:
            uiKeyboardType = .phonePad
        case .URL:
            uiKeyboardType = .URL
        case .namePhonePad:
            uiKeyboardType = .namePhonePad
        }
        self.keyboardType(uiKeyboardType)
        #else
        // macOS doesn't support keyboardType
        self
        #endif
    }
    
    /// Apply content type in a cross-platform way
    @ViewBuilder
    func compatibleTextContentType(_ type: String) -> some View {
        #if os(iOS)
        // Convert string to UITextContentType
        if let contentType = UITextContentType(rawValue: type) {
            self.textContentType(contentType)
        } else {
            self
        }
        #else
        // macOS doesn't support textContentType
        self
        #endif
    }
    
    /// Apply submission behavior in a cross-platform way
    @ViewBuilder
    func compatibleSubmitLabel(_ label: CompatibleSubmitLabel) -> some View {
        #if os(iOS)
        if #available(iOS 15.0, *) {
            let submitLabel: SubmitLabel
            switch label {
            case .done:
                submitLabel = .done
            case .next:
                submitLabel = .next
            case .search:
                submitLabel = .search
            case .send:
                submitLabel = .send
            case .go:
                submitLabel = .go
            }
            self.submitLabel(submitLabel)
        } else {
            self
        }
        #else
        // macOS doesn't support submitLabel
        self
        #endif
    }
}

// Create cross-platform submit label enum
public enum CompatibleSubmitLabel {
    case done
    case next
    case search
    case send
    case go
}

// Focus state helpers
public enum TextFieldFocusIdentifier: Hashable {
    case email
    case password
    case username
    case name
    case firstName
    case lastName
    case phoneNumber
    case custom(String)
}

extension View {
    /// Apply focus in a cross-platform way
    @ViewBuilder
    func compatibleFocused<Value>(_ binding: FocusState<Value>.Binding, equals value: Value) -> some View where Value: Hashable {
        #if os(iOS) || os(macOS)
        if #available(iOS 15.0, macOS 12.0, *) {
            self.focused(binding, equals: value)
        } else {
            self
        }
        #else
        self
        #endif
    }
} 