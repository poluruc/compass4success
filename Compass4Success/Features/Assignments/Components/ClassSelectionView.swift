import SwiftUI

struct ClassSelectionView: View {
    let classes: [SchoolClass]
    @Binding var selectedClassIds: Set<String>
    
    public init(classes: [SchoolClass], selectedClassIds: Binding<Set<String>>) {
        self.classes = classes
        self._selectedClassIds = selectedClassIds
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Classes").font(.caption).foregroundColor(.secondary)
            WrapHStack(items: classes, id: \.id) { schoolClass in
                ClassSelectionButton(
                    schoolClass: schoolClass,
                    isSelected: selectedClassIds.contains(schoolClass.id),
                    onTap: {
                        if selectedClassIds.contains(schoolClass.id) {
                            selectedClassIds.remove(schoolClass.id)
                        } else {
                            selectedClassIds.insert(schoolClass.id)
                        }
                    }
                )
            }
            .padding(.vertical, 8)
            
            if selectedClassIds.isEmpty {
                Text("No Class Assigned")
                    .font(.caption2)
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
        }
    }
}

private struct ClassSelectionButton: View {
    let schoolClass: SchoolClass
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if isSelected { Image(systemName: "checkmark").font(.caption) }
                Text(schoolClass.name).fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .accentColor)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.accentColor, lineWidth: isSelected ? 0 : 1)
            )
            .cornerRadius(18)
            .shadow(color: isSelected ? Color.accentColor.opacity(0.15) : .clear, radius: 4, x: 0, y: 2)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
    }
} 
