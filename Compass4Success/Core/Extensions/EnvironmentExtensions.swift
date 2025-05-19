import SwiftUI
import Foundation

extension EnvironmentValues {
    // Add dismiss environment value for macOS compatibility
    #if os(macOS)
    public var dismiss: DismissAction {
        get { self[DismissActionKey.self] }
        set { self[DismissActionKey.self] = newValue }
    }
    
    private struct DismissActionKey: EnvironmentKey {
        static let defaultValue: DismissAction = DismissAction()
    }
    #endif
}

#if os(macOS)
public struct DismissAction {
    fileprivate init() {}
    
    public func callAsFunction() {
        NSApplication.shared.keyWindow?.close()
    }
}
#endif
