import SwiftUI

#if os(macOS)
// Add UIKit color names to macOS for compatibility
extension NSColor {
    static var systemBackground: NSColor {
        return NSColor.windowBackgroundColor
    }
    
    static var systemGray6: NSColor {
        return NSColor.lightGray.withAlphaComponent(0.2)
    }
    
    static var secondarySystemBackground: NSColor {
        return NSColor.controlBackgroundColor
    }
    
    static var tertiarySystemBackground: NSColor {
        return NSColor.textBackgroundColor
    }
    
    static var systemGray5: NSColor {
        return NSColor.lightGray.withAlphaComponent(0.3)
    }
    
    static var systemGray4: NSColor {
        return NSColor.lightGray.withAlphaComponent(0.4)
    }
    
    static var systemGray3: NSColor {
        return NSColor.lightGray.withAlphaComponent(0.5)
    }
    
    static var systemGray2: NSColor {
        return NSColor.lightGray.withAlphaComponent(0.6)
    }
    
    static var systemGray: NSColor {
        return NSColor.lightGray
    }
}
#endif

extension Color {
    #if os(macOS)
    // Initialize with UIKit color names on macOS
    init(_ uiColor: NSColor) {
        self.init(nsColor: uiColor)
    }
    #endif
    
    // Common system colors that work across platforms
    static var systemBackground: Color {
        #if os(iOS)
        return Color(.systemBackground)
        #else
        return Color(NSColor.systemBackground)
        #endif
    }
    
    static var secondarySystemBackground: Color {
        #if os(iOS)
        return Color(.secondarySystemBackground)
        #else
        return Color(NSColor.secondarySystemBackground)
        #endif
    }
    
    static var tertiarySystemBackground: Color {
        #if os(iOS)
        return Color(.tertiarySystemBackground)
        #else
        return Color(NSColor.tertiarySystemBackground)
        #endif
    }
    
    static var systemGray6: Color {
        #if os(iOS)
        return Color(.systemGray6)
        #else
        return Color(NSColor.systemGray6)
        #endif
    }
}
