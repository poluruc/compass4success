import SwiftUI

struct RubricPickerView: View {
    let rubrics: [RubricTemplate]
    let onSelect: (RubricTemplate) -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selectedGrade: Int? = nil
    @State private var previewRubric: RubricTemplate? = nil
    
    private let gridColumns = [
        GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 16)
    ]
    
    var filteredRubrics: [RubricTemplate] {
        if let grade = selectedGrade {
            return rubrics.filter { $0.applicableGrades.contains(grade) }
        }
        return rubrics
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Grade filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        gradeChip(label: "All", grade: nil)
                        gradeChip(label: "JK", grade: 0)
                        ForEach(1...12, id: \.self) { grade in
                            gradeChip(label: "Gr. \(grade)", grade: grade)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 8)

                if filteredRubrics.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No rubrics found for this grade")
                            .font(.headline)
                        Text("Try selecting a different grade or view all rubrics")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    // Rubric grid
                    ScrollView {
                        LazyVGrid(columns: gridColumns, spacing: 16) {
                            ForEach(filteredRubrics) { rubric in
                                VStack(spacing: 0) {
                                    // Rubric card
                                    Button(action: {
                                        if previewRubric?.id == rubric.id {
                                            onSelect(rubric)
                                            dismiss()
                                        } else {
                                            previewRubric = rubric
                                        }
                                    }) {
                                        VStack(alignment: .leading, spacing: 12) {
                                            HStack {
                                                Text(rubric.title)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                                if previewRubric?.id == rubric.id {
                                                    Text("Tap to select")
                                                        .font(.caption)
                                                        .foregroundColor(.blue)
                                                }
                                            }
                                            
                                            Text(rubric.description)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .lineLimit(2)
                                            
                                            HStack(spacing: 6) {
                                                ForEach(rubric.applicableGrades.sorted(), id: \.self) { grade in
                                                    Text(grade == 0 ? "JK" : "Gr. \(grade)")
                                                        .font(.caption2)
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 4)
                                                        .background(Color.blue.opacity(0.12))
                                                        .foregroundColor(.blue)
                                                        .cornerRadius(6)
                                                }
                                            }
                                            
                                            if previewRubric?.id == rubric.id {
                                                Divider()
                                                    .padding(.vertical, 8)
                                                
                                                VStack(alignment: .leading, spacing: 16) {
                                                    Text("Rubric Structure")
                                                        .font(.subheadline)
                                                        .fontWeight(.medium)
                                                        .foregroundColor(.secondary)
                                                    
                                                    ForEach(rubric.criteria) { criterion in
                                                        VStack(alignment: .leading, spacing: 8) {
                                                            Text(criterion.name)
                                                                .font(.callout)
                                                                .fontWeight(.medium)
                                                            
                                                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                                                                ForEach(criterion.levels, id: \.level) { level in
                                                                    VStack(alignment: .leading, spacing: 4) {
                                                                        Text("Level \(level.level)")
                                                                            .font(.caption)
                                                                            .fontWeight(.medium)
                                                                            .foregroundColor(.blue)
                                                                        Text(level.description)
                                                                            .font(.caption)
                                                                            .foregroundColor(.secondary)
                                                                    }
                                                                    .padding(8)
                                                                    .background(Color(.systemGray6))
                                                                    .cornerRadius(8)
                                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(14)
                                        .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 2)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Select Rubric")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }

    private func gradeChip(label: String, grade: Int?) -> some View {
        Button(action: { selectedGrade = grade }) {
            Text(label)
                .font(.caption)
                .fontWeight(selectedGrade == grade ? .bold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(selectedGrade == grade ? Color.blue.opacity(0.18) : Color(.systemGray5))
                .foregroundColor(selectedGrade == grade ? .blue : .primary)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedGrade == grade ? Color.blue : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
} 