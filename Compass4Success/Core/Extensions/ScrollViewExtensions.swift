import SwiftUI

extension View {
    /// Wraps the view in a ScrollView with proper compatibility across platforms
    @ViewBuilder
    func adaptiveScrollView(axes: Axis.Set = .vertical) -> some View {
        #if os(iOS) || os(tvOS)
        ScrollView(axes) {
            self
        }
        #else
        ScrollView(axes, showsIndicators: true) {
            self
        }
        #endif
    }
}

// Static factory method for compatibility
extension View {
    static func compatibleScrollView<Content: View>(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> Content
    ) -> some View {
        #if os(macOS)
        ScrollView(axes, showsIndicators: showsIndicators) {
            content()
        }
        #else
        ScrollView(axes) {
            content()
        }
        #endif
    }
}

// Create a factory type to handle the creation of ScrollView instances
enum ScrollViewFactory {
    static func compatible<C: View>(
        _ axes: Axis.Set = .vertical, 
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> C
    ) -> some View {
        #if os(macOS)
        ScrollView(axes, showsIndicators: showsIndicators) {
            content()
        }
        #else
        ScrollView(axes) {
            content()
        }
        #endif
    }
}

// Type extension to provide the compatible static method for ScrollView
extension ScrollView where Content == EmptyView {
    static func compatible<C: View>(
        _ axes: Axis.Set = .vertical, 
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> C
    ) -> some View {
        ScrollViewFactory.compatible(axes, showsIndicators: showsIndicators, content: content)
    }
}

// Helper to handle toolbar issues
extension View {
    @ViewBuilder
    func compatibleToolbar<Content: ToolbarContent>(@ViewBuilder content: () -> Content) -> some View {
        self.toolbar {
            content()
        }
    }
}

// Helper for Section view in forms
extension View {
    @ViewBuilder
    func customSection(title: String) -> some View {
        Section(header: Text(title)) {
            self
        }
    }
}
