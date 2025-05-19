import SwiftUI

// A platform-independent way to specify navigation title display mode
public enum PlatformNavigationTitleDisplayMode {
    case automatic
    case inline
    case large
}

extension View {
    // Cross-platform safe modifiers for navigation bar title display mode
    @ViewBuilder
    func adaptiveNavigationBarTitleDisplayMode(_ mode: PlatformNavigationTitleDisplayMode) -> some View {
        #if os(iOS) || os(tvOS)
        if #available(iOS 14.0, tvOS 14.0, *) {
            switch mode {
            case .automatic:
                self.navigationBarTitleDisplayMode(.automatic)
            case .inline:
                self.navigationBarTitleDisplayMode(.inline)
            case .large:
                self.navigationBarTitleDisplayMode(.large)
            }
        } else {
            self
        }
        #else
        // Not supported on macOS, just return the view as is
        self
        #endif
    }
    
    // A helper extension for toolbar item placement that works across platforms
    @ViewBuilder
    func adaptiveToolbarItem<Content: View>(
        placement: ToolbarItemPlacement,
        @ViewBuilder content: () -> Content
    ) -> some View {
        #if os(iOS) || os(tvOS)
        toolbar {
            ToolbarItem(placement: placement) {
                content()
            }
        }
        #elseif os(macOS)
        toolbar {
            // On macOS, adapt iOS placements to macOS equivalents
            ToolbarItem(
                placement: adaptedToolbarPlacement(from: placement),
                content: content
            )
        }
        #else
        self
        #endif
    }
    
    // Helper method to adapt iOS toolbar placement to macOS
    private func adaptedToolbarPlacement(from placement: ToolbarItemPlacement) -> ToolbarItemPlacement {
        #if os(macOS)
        // Since ToolbarItemPlacement isn't Equatable and navigationBar placements aren't available on macOS,
        // we map using string representation
        let placementString = String(describing: placement)
        
        // Handle iOS toolbar placements and map them to appropriate macOS equivalents
        if placementString.contains("navigationBarLeading") {
            return .navigation
        } else if placementString.contains("navigationBarTrailing") {
            return .primaryAction
        } else if placementString.contains("cancellationAction") {
            return .cancellationAction
        } else if placementString.contains("confirmationAction") {
            return .confirmationAction
        } else {
            return .automatic
        }
        #else
        return placement
        #endif
    }
}
