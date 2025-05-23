import SwiftUI

public struct RubricSelectionView: View {
    let rubrics: [RubricTemplate]
    @Binding var selectedRubric: RubricTemplate?
    @Binding var showingRubricPicker: Bool
    
    public init(rubrics: [RubricTemplate], selectedRubric: Binding<RubricTemplate?>, showingRubricPicker: Binding<Bool>) {
        self.rubrics = rubrics
        self._selectedRubric = selectedRubric
        self._showingRubricPicker = showingRubricPicker
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rubric").font(.caption).foregroundColor(.secondary)
            if let rubric = selectedRubric {
                VStack(alignment: .leading, spacing: 4) {
                    Text(rubric.title)
                        .font(.headline)
                    Text(rubric.rubricDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("No rubric selected")
                    .foregroundColor(.secondary)
            }
            Button(action: { showingRubricPicker = true }) {
                Text(selectedRubric == nil ? "Select Rubric" : "Change Rubric")
            }
        }
    }
} 