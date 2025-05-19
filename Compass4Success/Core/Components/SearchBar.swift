import SwiftUI

/// A reusable search bar component that can be used across the app
public struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    var onCommit: (() -> Void)?
    var onCancel: (() -> Void)?
    
    @State private var isEditing = false
    
    public init(
        text: Binding<String>,
        placeholder: String = "Search",
        onCommit: (() -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onCommit = onCommit
        self.onCancel = onCancel
    }
    
    public var body: some View {
        HStack {
            // Search icon and TextField
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
                
                #if os(iOS)
                TextField(placeholder, text: $text, onCommit: {
                    onCommit?()
                })
                .keyboardType(.default)
                .disableAutocorrection(true)
                #else
                TextField(placeholder, text: $text, onCommit: {
                    onCommit?()
                })
                #endif
                
                // Clear button
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(.trailing, 8)
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Cancel button for iOS
            #if os(iOS)
            if isEditing {
                Button("Cancel") {
                    text = ""
                    isEditing = false
                    
                    // Dismiss keyboard
                    #if os(iOS)
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    #endif
                    
                    onCancel?()
                }
                .padding(.leading, 8)
                .transition(.move(edge: .trailing))
                .animation(.default, value: isEditing)
            }
            #endif
        }
        .onTapGesture {
            isEditing = true
        }
    }
}

// A simple search bar modifier to easily add search functionality
extension View {
    func addSearchBar(
        searchText: Binding<String>,
        placeholder: String = "Search",
        onCommit: (() -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) -> some View {
        VStack(spacing: 0) {
            SearchBar(
                text: searchText,
                placeholder: placeholder
            )
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            self
        }
    }
}

#if DEBUG
struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant(""))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif 