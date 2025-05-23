import SwiftUI

public struct AssignmentBasicDetailsView: View {
    @Binding var title: String
    @Binding var description: String
    
    public init(title: Binding<String>, description: Binding<String>) {
        self._title = title
        self._description = description
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TextField("Title", text: $title)
                .appTextFieldStyle()
            TextField("Description", text: $description)
                .appTextFieldStyle()
        }
    }
} 