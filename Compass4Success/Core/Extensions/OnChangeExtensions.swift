import SwiftUI

extension View {
    /// A cross-platform, cross-version compatible onChange implementation
    @ViewBuilder
    func compatibleOnChange<Value: Equatable>(of value: Value, perform action: @escaping (Value) -> Void) -> some View {
        #if os(iOS) || os(macOS)
        if #available(iOS 17.0, macOS 14.0, *) {
            // New onChange signature in iOS 17/macOS 14
            self.onChange(of: value) { oldValue, newValue in
                action(newValue)
            }
        } else {
            // Older onChange signature
            self.onChange(of: value) { newValue in
                action(newValue)
            }
        }
        #else
        // Basic fallback for other platforms
        self.onChange(of: value) { newValue in
            action(newValue)
        }
        #endif
    }
    
    /// A cross-platform, cross-version compatible onChange implementation with oldValue
    @ViewBuilder
    func compatibleOnChangeWithOldValue<Value: Equatable>(
        of value: Value, 
        perform action: @escaping (Value, Value) -> Void
    ) -> some View {
        #if os(iOS) || os(macOS)
        if #available(iOS 17.0, macOS 14.0, *) {
            // New onChange signature in iOS 17/macOS 14
            self.onChange(of: value) { oldValue, newValue in
                action(oldValue, newValue)
            }
        } else {
            // Track previous value manually for older versions
            ChangeObserver(value: value, action: action)
        }
        #else
        // Basic fallback for other platforms with manual tracking
        ChangeObserver(value: value, action: action)
        #endif
    }
}

/// Helper struct to track value changes for older SwiftUI versions
private struct ChangeObserver<Value: Equatable>: View {
    let value: Value
    let action: (Value, Value) -> Void
    
    @State private var oldValue: Value
    
    init(value: Value, action: @escaping (Value, Value) -> Void) {
        self.value = value
        self.action = action
        self._oldValue = State(initialValue: value)
    }
    
    var body: some View {
        EmptyView()
            .onChange(of: value) { newValue in
                action(oldValue, newValue)
                oldValue = newValue
            }
    }
} 