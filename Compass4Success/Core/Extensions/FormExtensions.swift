import SwiftUI

extension Form {
    /// Compatibility layer for Form sections with headers
    @ViewBuilder
    static func compatibleSection<Content: View, Header: View>(
        @ViewBuilder content: () -> Content,
        @ViewBuilder header: () -> Header
    ) -> some View {
        Section {
            content()
        } header: {
            header()
        }
    }
}

extension Text {
    /// Helper for text with date formatter
    static func dateText(_ date: Date, formatter: DateFormatter) -> Text {
        Text(formatter.string(from: date))
    }
}
