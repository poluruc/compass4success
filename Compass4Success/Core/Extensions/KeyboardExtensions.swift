import SwiftUI
#if os(iOS)
import UIKit
#endif

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
        switch type {
        case .default:
            self.keyboardType(.default)
        case .emailAddress:
            self.keyboardType(.emailAddress)
        case .numberPad:
            self.keyboardType(.numberPad)
        case .decimalPad:
            self.keyboardType(.decimalPad)
        case .phonePad:
            self.keyboardType(.phonePad)
        case .URL:
            self.keyboardType(.URL)
        case .namePhonePad:
            self.keyboardType(.namePhonePad)
        }
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
        let contentType = UITextContentType(rawValue: type)
        self.textContentType(contentType)
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
            switch label {
            case .done:
                self.submitLabel(.done)
            case .next:
                self.submitLabel(.next)
            case .search:
                self.submitLabel(.search)
            case .send:
                self.submitLabel(.send)
            case .go:
                self.submitLabel(.go)
            }
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