import SwiftUI

struct EditAssignmentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var description: String
    @State private var dueDate: Date
    @State private var selectedClassId: String
    @State private var category: AssignmentCategory
    @State private var points: String
    @State private var selectedRubric: RubricTemplate?
    @State private var showingRubricPicker = false
    let classes: [SchoolClass]
    let rubrics: [RubricTemplate]
    let originalAssignment: Assignment
    let onSave: (Assignment) -> Void
    let onCancel: () -> Void

    init(assignment: Assignment, classes: [SchoolClass], rubrics: [RubricTemplate], onSave: @escaping (Assignment) -> Void, onCancel: @escaping () -> Void) {
        self.originalAssignment = assignment
        self.classes = classes
        self.rubrics = rubrics
        self.onSave = onSave
        self.onCancel = onCancel
        _title = State(initialValue: assignment.title)
        _description = State(initialValue: assignment.assignmentDescription)
        _dueDate = State(initialValue: assignment.dueDate)
        _selectedClassId = State(initialValue: assignment.classId ?? "")
        _category = State(initialValue: AssignmentCategory(rawValue: assignment.category) ?? .assignment)
        _points = State(initialValue: String(Int(assignment.totalPoints)))
        if let rubricId = assignment.rubricId, let rubric = rubrics.first(where: { $0.id == rubricId }) {
            _selectedRubric = State(initialValue: rubric)
        } else {
            _selectedRubric = State(initialValue: nil)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Assignment Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                        .lineLimit(4)
                    Picker("Class", selection: $selectedClassId) {
                        Text("Select a class").tag("")
                        ForEach(classes) { schoolClass in
                            Text(schoolClass.name).tag(schoolClass.id)
                        }
                    }
                    Picker("Category", selection: $category) {
                        ForEach(AssignmentCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    TextField("Points", text: $points)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                }
                Section(header: Text("Rubric")) {
                    if let rubric = selectedRubric {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(rubric.title)
                                .font(.headline)
                            Text(rubric.description)
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
            .navigationTitle("Edit Assignment")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAssignment()
                    }
                    .disabled(title.isEmpty || selectedClassId.isEmpty)
                }
            }
            .sheet(isPresented: $showingRubricPicker) {
                RubricPickerView(rubrics: rubrics) { rubric in
                    selectedRubric = rubric
                }
            }
        }
    }

    private func saveAssignment() {
        guard let totalPoints = Double(points) else { return }
        let updated = originalAssignment
        updated.title = title
        updated.assignmentDescription = description
        updated.dueDate = dueDate
        updated.classId = selectedClassId
        updated.category = category.rawValue
        updated.totalPoints = totalPoints
        updated.rubricId = selectedRubric?.id
        onSave(updated)
        dismiss()
    }
} 