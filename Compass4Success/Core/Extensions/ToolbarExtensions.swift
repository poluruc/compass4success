import SwiftUI

@available(macOS 13.0, iOS 16.0, *)
extension View {
    /// Cross-platform compatible toolbar modifier
    @ViewBuilder
    func adaptiveToolbar<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        #if os(iOS) || os(tvOS)
        self.toolbar {
            content()
        }
        #else
        self.toolbar {
            content()
        }
        #endif
    }
    
    /// Handle presentationDetents compatibility issue
    @ViewBuilder
    func adaptivePresentationDetents(_ detents: Set<PresentationDetent>) -> some View {
        #if os(iOS) && canImport(UIKit)
        if #available(iOS 16.0, *) {
            self.presentationDetents(detents)
        } else {
            self
        }
        #else
        self
        #endif
    }
}
