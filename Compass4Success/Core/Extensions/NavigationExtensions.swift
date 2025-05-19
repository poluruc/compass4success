import SwiftUI

// Helps with NavigationView compatibility across platforms and SwiftUI versions
extension View {
    /// Cross-platform navigation stack
    @ViewBuilder
    func adaptiveNavigationView<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        #if os(iOS) || os(tvOS)
            if #available(iOS 16.0, tvOS 16.0, *) {
                NavigationStack {
                    content()
                }
            } else {
                // Fallback on earlier versions
                NavigationView {
                    content()
                }
            }
        #else
            NavigationView {
                content()
            }
        #endif
    }
    
    /// Safely apply navigationBarTitleDisplayMode
    @ViewBuilder
    func compatibleNavigationBarTitleDisplayMode(_ mode: CompatibleTitleDisplayMode) -> some View {
        #if os(iOS)
        if #available(iOS 14.0, *) {
            switch mode {
            case .inline:
                self.navigationBarTitleDisplayMode(.inline)
            case .large:
                self.navigationBarTitleDisplayMode(.large)
            case .automatic:
                self.navigationBarTitleDisplayMode(.automatic)
            }
        } else {
            self
        }
        #elseif os(macOS)
        // macOS doesn't support navigationBarTitleDisplayMode
        self
        #else
        self
        #endif
    }
    
    /// Unified toolbar modifier that resolves ambiguity
    @ViewBuilder
    func compatibleToolbar<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        self.toolbar {
            content()
        }
    }
    
    /// Safe ToolbarItem placement for cross-platform support
    @ViewBuilder
    func safeToolbarItem<Content: View>(
        placement: CompatibleToolbarPlacement,
        @ViewBuilder content: () -> Content
    ) -> some View {
        #if os(iOS)
        self.toolbar {
            ToolbarItem(placement: placement.toiOSPlacement()) {
                content()
            }
        }
        #elseif os(macOS)
        self.toolbar {
            ToolbarItem(placement: placement.toMacOSPlacement()) {
                content()
            }
        }
        #else
        self.toolbar {
            ToolbarItem {
                content()
            }
        }
        #endif
    }
    
    // Safely unwrap generic Content type from NavigationView
    @ViewBuilder
    func typeSafeNavigationView() -> some View {
        NavigationView {
            self
        }
    }
}

// Wrapper for content in a NavigationView with safe generic handling
struct SafeNavigationView<Content: View>: View {
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        NavigationView {
            content
        }
    }
}

// Cross-platform compatible title display mode
public enum CompatibleTitleDisplayMode {
    case automatic
    case inline
    case large
}

// Cross-platform toolbar item placement
public enum CompatibleToolbarPlacement {
    case automatic
    case navigation
    case primaryAction
    case cancellationAction
    case confirmationAction
    case destructiveAction
    case principal
    case navigationBarLeading
    case navigationBarTrailing
    case bottomBar
    case status
    
    #if os(iOS)
    func toiOSPlacement() -> ToolbarItemPlacement {
        switch self {
        case .automatic:
            return .automatic
        case .navigation:
            return .navigation
        case .primaryAction:
            return .primaryAction
        case .cancellationAction:
            return .cancellationAction
        case .confirmationAction:
            return .confirmationAction
        case .destructiveAction:
            return .destructiveAction
        case .principal:
            return .principal
        case .navigationBarLeading:
            if #available(iOS 14.0, *) {
                return .navigationBarLeading
            } else {
                return .automatic
            }
        case .navigationBarTrailing:
            if #available(iOS 14.0, *) {
                return .navigationBarTrailing
            } else {
                return .automatic
            }
        case .bottomBar:
            if #available(iOS 14.0, *) {
                return .bottomBar
            } else {
                return .automatic
            }
        case .status:
            if #available(iOS 14.0, *) {
                return .status
            } else {
                return .automatic
            }
        }
    }
    #endif
    
    #if os(macOS)
    func toMacOSPlacement() -> ToolbarItemPlacement {
        switch self {
        case .automatic:
            return .automatic
        case .navigation, .navigationBarLeading:
            return .navigation
        case .primaryAction, .navigationBarTrailing, .confirmationAction:
            return .primaryAction
        case .cancellationAction:
            return .cancellationAction
        case .destructiveAction:
            return .automatic
        case .principal:
            return .principal
        case .bottomBar:
            return .automatic
        case .status:
            return .automatic
        }
    }
    #endif
}
