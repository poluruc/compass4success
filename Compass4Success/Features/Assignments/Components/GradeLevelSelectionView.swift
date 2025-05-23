import SwiftUI

public struct GradeLevelSelectionView: View {
    @Binding var selectedGradeLevels: Set<String>
    
    public init(selectedGradeLevels: Binding<Set<String>>) {
        self._selectedGradeLevels = selectedGradeLevels
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Grade Levels").font(.caption).foregroundColor(.secondary)
            WrapHStack(items: GradeLevel.allCases, id: \.self) { grade in
                GradeLevelButton(
                    grade: grade,
                    isSelected: selectedGradeLevels.contains(grade.rawValue),
                    onTap: {
                        if selectedGradeLevels.contains(grade.rawValue) {
                            selectedGradeLevels.remove(grade.rawValue)
                        } else {
                            selectedGradeLevels.insert(grade.rawValue)
                        }
                    }
                )
            }
            .padding(.vertical, 8)
            
            if selectedGradeLevels.isEmpty {
                Text("No Grade Level")
                    .font(.caption2)
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
        }
    }
}

private struct GradeLevelButton: View {
    let grade: GradeLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if isSelected { Image(systemName: "checkmark").font(.caption) }
                Text(grade.rawValue).fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.green : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .green)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.green, lineWidth: isSelected ? 0 : 1)
            )
            .cornerRadius(18)
            .shadow(color: isSelected ? Color.green.opacity(0.15) : .clear, radius: 4, x: 0, y: 2)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
    }
} 