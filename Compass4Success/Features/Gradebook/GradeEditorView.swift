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
    
    // Get existing submission if it exists
    private var existingSubmission: AssignmentSubmission? {
        // Convert from CoreSubmission to AssignmentSubmission if found
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
                
                Section(header: Text("Feedback")) {
                    TextEditor(text: $feedback)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("Notes (Private)")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
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
            .platformSpecificTitleDisplayMode()            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSubmitting)
                }
            }
            .onAppear {
                loadExistingSubmission()
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
    
    private func saveGrade() {
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
