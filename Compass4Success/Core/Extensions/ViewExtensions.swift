import SwiftUI

extension View {
    /// Platform-compatible presentation detent modifier
    /// This is a placeholder function that handles availability checking
    /// and allows callers to safely use presentation detent features
    /// 
    /// Example usage:
    /// ```
    /// .platformPresentationDetent()
    /// #if os(iOS)
    /// .if #available(iOS 16.0, *) {
    ///     presentationDetent(.medium)
    /// }
    /// #endif
    /// ```
    @ViewBuilder
    func platformPresentationDetent() -> some View {
        #if os(iOS)
        if #available(iOS 16.0, *) {
            // Simply return the view itself on iOS 16+ and let the caller apply the proper presentation detent
            self
        } else {
            // On earlier iOS versions, just return the view as is
            self
        }
        #else
        // On non-iOS platforms, just return the view as is
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
    
    /// Convenience modifier for sheets that automatically applies medium presentation detent
    /// on iOS 16+ and does nothing on other platforms
    @ViewBuilder
    func adaptiveSheet<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            content()
                #if os(iOS)
                .if16Available { view in
                    if #available(iOS 16.0, *) {
                        view.presentationDetents([.medium, .large])
                    } else {
                        view
                    }
                }
                #endif
        }
    }
    
    /// Helper to conditionally apply iOS 16 specific modifiers
    @ViewBuilder
    func if16Available<Content: View>(@ViewBuilder transform: (Self) -> Content) -> some View {
        #if os(iOS)
        if #available(iOS 16.0, *) {
            transform(self)
        } else {
            self
        }
        #else
        self
        #endif
    }
} 