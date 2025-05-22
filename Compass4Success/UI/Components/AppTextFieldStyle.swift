import SwiftUI

struct AppTextFieldStyle: ViewModifier {
    @FocusState private var isFocused: Bool
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color.accentColor : Color(.systemGray4), lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
            .focused($isFocused)
    }
}

extension View {
    func appTextFieldStyle() -> some View {
        self.modifier(AppTextFieldStyle())
    }
} 