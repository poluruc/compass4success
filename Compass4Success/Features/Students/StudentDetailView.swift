import SwiftUI
import Combine

struct StudentDetailView: View {
    enum Result {
        case success
        case failure(Error)
    }
    
    let student: Student
    var onComplete: (Result) -> Void
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var studentService = StudentService()
    @State private var firstName: String
    @State private var lastName: String
    @State private var email: String
    @State private var grade: String
    @State private var studentNumber: String
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var cancellables = Set<AnyCancellable>()
    
    init(student: Student, onComplete: @escaping (Result) -> Void) {
        self.student = student
        self.onComplete = onComplete
        _firstName = State(initialValue: student.firstName)
        _lastName = State(initialValue: student.lastName)
        _email = State(initialValue: student.email)
        _grade = State(initialValue: student.grade)
        _studentNumber = State(initialValue: student.studentNumber)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Student Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                    
                    Picker("Grade Level", selection: $grade) {
                        Text("Select Grade").tag("")
                        ForEach(["K", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"], id: \.self) { grade in
                            Text("Grade \(grade)").tag(grade)
                        }
                    }
                    
                    TextField("Student ID", text: $studentNumber)
                        .disabled(true) // Don't allow changing student ID after creation
                }
                
                Section(header: Text("Academic Performance")) {
                    ForEach(Array(student.courses), id: \.id) { course in
                        HStack {
                            Text(course.name)
                            Spacer()
                            if let finalGrade = course.finalGrade {
                                Text("\(finalGrade, specifier: "%.1f")%")
                                    .foregroundColor(finalGrade >= 70 ? .green : .red)
                            } else {
                                Text("N/A")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if student.courses.isEmpty {
                        Text("No courses assigned")
                            .foregroundColor(.secondary)
                    }
                }
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Edit Student")
            .disabled(isLoading)
            .overlay(
                Group {
                    if isLoading {
                        ProgressView()
                    }
                }
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updateStudent()
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty || isLoading)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func updateStudent() {
        isLoading = true
        errorMessage = ""
        
        // Create an updated student object
        let updatedStudent = student
        updatedStudent.firstName = firstName
        updatedStudent.lastName = lastName
        updatedStudent.email = email
        updatedStudent.grade = grade
        
        studentService.updateStudent(updatedStudent) { result in
                isLoading = false
                
                switch result {
                case .success:
                    onComplete(.success)
                    dismiss()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
    }
}

#Preview {
    let mockStudent = Student()
    mockStudent.firstName = "John"
    mockStudent.lastName = "Doe"
    mockStudent.email = "john.doe@example.com"
    mockStudent.grade = "9"
    mockStudent.studentNumber = "12345"
    
    return StudentDetailView(student: mockStudent) { result in
        print("Student updated with result: \(result)")
    }
}