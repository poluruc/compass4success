import SwiftUI

extension View {
    /// Platform-compatible presentation detent modifier
    /// Returns the original view on platforms where presentationDetent is not available
    @ViewBuilder
    func platformPresentationDetent() -> some View {
        #if os(iOS)
        if #available(iOS 16.0, *) {
            self.presentationDetent(.large)
        } else {
            self
        }
        #else
        self
        #endif
    }
    
    /// Platform-compatible navigationBarTrailing placement
    /// Uses automatic toolbar placement on macOS
    @ViewBuilder
    func platformNavigationBarTrailing<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        #if os(iOS)
        self.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                content()
            }
        }
        #else
        self.toolbar {
            ToolbarItem(placement: .automatic) {
                content()
            }
        }
        #endif
    }
    
    /// Platform-compatible toolbar with platform-specific placement
    @ViewBuilder
    func platformToolbarItem<Content: View>(placement: ToolbarItemPlacement, @ViewBuilder content: () -> Content) -> some View {
        #if os(iOS)
        self.toolbar {
            ToolbarItem(placement: placement) {
                content()
            }
        }
        #else
        self.toolbar {
            ToolbarItem(placement: .automatic) {
                content()
            }
        }
        #endif
    }
    
    /// Applies a modifier if the condition is true
    @ViewBuilder func applyIf<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Applies a modifier if the condition is true, with support for availability checking
    @ViewBuilder func applyIfAutoclosure<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}

/// Platform-compatible extension for PresentationDetent
#if os(iOS)
extension PresentationDetent {
    /// Returns a large detent on iOS 16+ and has no effect on other platforms
    public static var large: PresentationDetent {
        if #available(iOS 16.0, *) {
            return .large
        } else {
            // This is a fallback that won't actually be used since the modifier itself is unavailable
            return .fraction(0.8)
        }
    }
}
#endif 