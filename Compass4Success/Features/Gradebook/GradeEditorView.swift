import SwiftUI

struct GradeEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let student: Student
    let assignment: Assignment
    let classInfo: SchoolClass
    
    @State private var score: String = ""
    @State private var feedback: String = ""
    @State private var status: AssignmentSubmission.SubmissionStatus = .notSubmitted
    @State private var notes: String = ""
    @State private var isSubmitting = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    // Rubric scoring
    @State private var rubric: RubricTemplate? = nil
    @State private var selectedLevels: [String: Int] = [:] // criterion name -> level
    
    private var existingSubmission: AssignmentSubmission? {
        if let coreSubmission = assignment.submissions.first(where: { $0.studentId == student.id }) {
            let submission = AssignmentSubmission()
            submission.id = coreSubmission.id
            submission.studentId = coreSubmission.studentId
            submission.score = Int(coreSubmission.score ?? 0)
            return submission
        }
        return nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Student Information")) {
                    studentInfoRow(label: "Name", value: student.fullName)
                    studentInfoRow(label: "ID", value: student.studentNumber)
                    studentInfoRow(label: "Email", value: student.email)
                }
                
                Section(header: Text("Assignment Details")) {
                    studentInfoRow(label: "Title", value: assignment.title)
                    studentInfoRow(label: "Due Date", value: assignment.formattedDueDate)
                    studentInfoRow(label: "Total Points", value: "\(assignment.totalPoints)")
                }
                
                if let rubric = rubric {
                    Section(header: HStack {
                        Image(systemName: "list.bullet.rectangle")
                            .foregroundColor(.blue)
                        Text("Rubric Scoring")
                    }) {
                        ForEach(rubric.criteria) { criterion in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(criterion.name)
                                    .font(.headline)
                                HStack {
                                    ForEach(criterion.levels, id: \ .level) { level in
                                        Button(action: {
                                            selectedLevels[criterion.name] = level.level
                                        }) {
                                            VStack {
                                                Text("L\(level.level)")
                                                    .fontWeight(.bold)
                                                    .foregroundColor(selectedLevels[criterion.name] == level.level ? .white : .primary)
                                                Text(level.description)
                                                    .font(.caption2)
                                                    .foregroundColor(selectedLevels[criterion.name] == level.level ? .white : .secondary)
                                                    .multilineTextAlignment(.center)
                                                    .frame(width: 80)
                                            }
                                            .padding(8)
                                            .background(selectedLevels[criterion.name] == level.level ? Color.blue : Color(.systemGray5))
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(selectedLevels[criterion.name] == level.level ? Color.blue : Color(.systemGray4), lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        Divider()
                        HStack {
                            Text("Auto-calculated Score:")
                            Spacer()
                            Text("\(autoCalculatedScore, specifier: "%.0f") / \(assignment.totalPoints, specifier: "%.0f")")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 4)
                    }
                } else {
                    Section(header: Text("Grade")) {
                        #if os(iOS)
                        TextField("Score", text: $score)
                            .keyboardType(.numberPad)
                        #else
                        TextField("Score", text: $score)
                        #endif
                        
                        HStack {
                            Text("Status")
                            Spacer()
                            Picker("Status", selection: $status) {
                                ForEach(AssignmentSubmission.SubmissionStatus.allCases, id: \.self) { status in
                                    Text(status.rawValue).tag(status)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        if let existingSubmission = existingSubmission, 
                           let existingScore = existingSubmission.score {
                            HStack {
                                Text("Current Grade")
                                Spacer()
                                Text("\(existingScore)/\(assignment.totalPoints)")
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
                
                Section(header: Text("Feedback")) {
                    TextEditor(text: $feedback)
                        .frame(minHeight: 100)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .padding(.vertical, 4)
                    Text("Tip: Give specific, actionable feedback to help the student improve.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Notes (Private)")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                Section {
                    Button(action: saveGrade) {
                        if isSubmitting {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Save Grade")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .disabled(isSubmitting)
                    .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle("Grade Assignment")
            .platformSpecificTitleDisplayMode()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSubmitting)
                }
            }
            .onAppear {
                loadExistingSubmission()
                loadRubricIfNeeded()
            }
            .alert(alertMessage, isPresented: $showingAlert) {
                Button("OK", role: .cancel) {
                    if alertMessage.contains("Success") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func studentInfoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
    
    private func loadExistingSubmission() {
        if let submission = existingSubmission {
            if let existingScore = submission.score {
                score = "\(existingScore)"
            }
            
            feedback = submission.feedback
            notes = submission.notes
            status = submission.statusEnum
        }
    }
    
    private func loadRubricIfNeeded() {
        if let rubricId = assignment.rubricId {
            rubric = RubricLoader.loadAllRubrics().first(where: { $0.id == rubricId })
            // Preselect levels if needed
            if let rubric = rubric {
                for criterion in rubric.criteria {
                    selectedLevels[criterion.name] = criterion.levels.first?.level
                }
            }
        }
    }
    
    private var autoCalculatedScore: Double {
        guard let rubric = rubric else { return 0 }
        let totalLevels = rubric.criteria.count
        guard totalLevels > 0 else { return 0 }
        let maxLevel = rubric.criteria.first?.levels.last?.level ?? 4
        let sum = rubric.criteria.reduce(0) { acc, criterion in
            acc + (selectedLevels[criterion.name] ?? 1)
        }
        // Score is proportional to selected levels
        let percent = Double(sum) / Double(totalLevels * maxLevel)
        return percent * assignment.totalPoints
    }
    
    private func saveGrade() {
        if rubric != nil {
            // Use auto-calculated score
            score = String(Int(autoCalculatedScore))
        }
        // Validate score input
        guard status != .graded || !score.isEmpty else {
            alertMessage = "Please enter a score for the graded submission."
            showingAlert = true
            return
        }
        
        if let scoreValue = Int(score), scoreValue > Int(assignment.totalPoints) {
            alertMessage = "Score cannot exceed total points (\(Int(assignment.totalPoints)))."
            showingAlert = true
            return
        }
        
        isSubmitting = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // In a real app, this would update the database
            isSubmitting = false
            alertMessage = "Grade saved successfully!"
            showingAlert = true
        }
    }
}

struct GradeEditorView_Previews: PreviewProvider {
    static var previews: some View {
        let mockStudent = Student()
        mockStudent.firstName = "John"
        mockStudent.lastName = "Smith"
        mockStudent.email = "john.smith@school.edu"
        mockStudent.studentNumber = "12345"
        
        let mockAssignment = Assignment()
        mockAssignment.title = "Algebra Quiz"
        mockAssignment.dueDate = Date()
        mockAssignment.totalPoints = 100
        
        let mockClass = SchoolClass()
        mockClass.name = "Algebra"
        mockClass.clazzCode = "MATH101"
        
        return GradeEditorView(
            student: mockStudent,
            assignment: mockAssignment,
            classInfo: mockClass
        )
    }
}
