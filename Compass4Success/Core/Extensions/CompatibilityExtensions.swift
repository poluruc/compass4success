import SwiftUI

// Adding availability to the extension to fix PresentationDetent compatibility
@available(macOS 13.0, iOS 16.0, *)
extension View {
    /// Apply presentation detents conditionally based on platform version
    @ViewBuilder
    func compatiblePresentationDetents(_ detents: Set<PresentationDetent>) -> some View {
        #if os(iOS)
        self.presentationDetents(detents)
        #elseif os(macOS)
        self.presentationDetents(detents)
        #else
        self
        #endif
    }
    
    /// Apply a single detent conditionally based on platform version
    @ViewBuilder
    func compatiblePresentationDetent(_ detent: PresentationDetent) -> some View {
        self.compatiblePresentationDetents([detent])
    }
}

// Create a separate extension for TextInputAutocapitalization that's only available on iOS
#if os(iOS)
// TextField extension to handle autocapitalization differences across versions
@available(iOS 16.0, *)
extension TextField {
    func compatibleAutocapitalization(_ type: TextInputAutocapitalization) -> some View {
        return self.textInputAutocapitalization(type)
    }
}
#endif

// Fix the ButtonStyle compatibility - create concrete button style types
// Define custom button styles that can be used cross-platform
struct CompatibleBorderedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1))
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

struct CompatibleProminentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.accentColor))
            .foregroundColor(.white)
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

struct CompatibleBorderlessButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}
