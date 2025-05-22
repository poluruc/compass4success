import SwiftUI

struct AppTextFieldFocusModifier: ViewModifier {
    @FocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color.accentColor : Color.accentColor.opacity(0.25), lineWidth: isFocused ? 2 : 1)
            )
            .font(.body)
            .foregroundColor(.primary)
            .shadow(color: isFocused ? Color.accentColor.opacity(0.10) : Color.black.opacity(0.03), radius: isFocused ? 4 : 2, x: 0, y: 1)
            .focused($isFocused)
    }
}

extension View {
    func appTextFieldStyle() -> some View {
        self.modifier(AppTextFieldFocusModifier())
    }
}