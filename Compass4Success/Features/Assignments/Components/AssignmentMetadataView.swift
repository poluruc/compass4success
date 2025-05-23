import SwiftUI

public struct AssignmentMetadataView: View {
    @Binding var category: AssignmentCategory
    @Binding var points: String
    @Binding var dueDate: Date
    
    public init(category: Binding<AssignmentCategory>, points: Binding<String>, dueDate: Binding<Date>) {
        self._category = category
        self._points = points
        self._dueDate = dueDate
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("Category")
                    .font(.caption)
                    .foregroundColor(.secondary)
                CategoryPicker(selectedCategory: $category)
            }
            
            HStack {
                Text("Points")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("Points", text: $points)
                    .keyboardType(.numberPad)
                    .appTextFieldStyle()
            }
            
            HStack {
                Text("Due Date")
                    .font(.caption)
                    .foregroundColor(.secondary)
                DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
            }
        }
    }
} 