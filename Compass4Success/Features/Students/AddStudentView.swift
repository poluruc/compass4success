import SwiftUI
import Combine

struct AddStudentView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var studentService = StudentService()
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var grade = ""
    @State private var studentNumber = ""
    @State private var isGeneratingStudentNumber = false
    @State private var selectedClasses = Set<String>()
    @State private var showingClassPicker = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var cancellables = Set<AnyCancellable>()
    
    // Classes available for selection
    @State private var availableClasses: [SchoolClass] = []
    
    // Callback for when student is created
    var onComplete: (Result<Student, Error>) -> Void
    
    var formIsValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !grade.isEmpty && !studentNumber.isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Student Information")) {
                    TextField("First Name", text: $firstName)
                        .autocapitalization(.words)
                    
                    TextField("Last Name", text: $lastName)
                        .autocapitalization(.words)
                    
                    TextField("Email (Optional)", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    Picker("Grade Level", selection: $grade) {
                        Text("Select Grade").tag("")
                        ForEach(["K", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"], id: \.self) { grade in
                            Text("Grade \(grade)").tag(grade)
                        }
                    }
                    
                    HStack {
                        TextField("Student ID", text: $studentNumber)
                            .keyboardType(.numberPad)
                        
                        Button(action: generateStudentNumber) {
                            if isGeneratingStudentNumber {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Image(systemName: "arrow.triangle.2.circlepath")
                            }
                        }
                        .disabled(isGeneratingStudentNumber)
                    }
                }
                
                Section(header: Text("Class Enrollment")) {
                    if availableClasses.isEmpty {
                        Text("Loading classes...")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(availableClasses) { schoolClass in
                            Button {
                                toggleClass(schoolClass.id)
                            } label: {
                                HStack {
                                    Text("\(schoolClass.name) (\(schoolClass.courseCode))")
                                    Spacer()
                                    if selectedClasses.contains(schoolClass.id) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.accentColor)
                                    }
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        if !availableClasses.isEmpty {
                            Button("Select All") {
                                selectedClasses = Set(availableClasses.map { $0.id })
                            }
                            .disabled(selectedClasses.count == availableClasses.count)
                        }
                    }
                }
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Add Student")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        createStudent()
                    }
                    .disabled(!formIsValid || isLoading)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView("Creating student...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                loadClasses()
                if studentNumber.isEmpty {
                    generateStudentNumber()
                }
            }
        }
    }
    
    private func toggleClass(_ classId: String) {
        if selectedClasses.contains(classId) {
            selectedClasses.remove(classId)
        } else {
            selectedClasses.insert(classId)
        }
    }
    
    private func generateStudentNumber() {
        isGeneratingStudentNumber = true
        
        // In a real app, this would come from a service
        // Here we'll just create a random number
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let randomNumber = Int.random(in: 100000...999999)
            self.studentNumber = String(randomNumber)
            self.isGeneratingStudentNumber = false
        }
    }
    
    private func loadClasses() {
        // In a real app, you would fetch classes from a service
        // Here we'll create mock data
        let mockClasses = [
            SchoolClass(id: "1", name: "Algebra I", courseCode: "MATH101", gradeLevel: "9"),
            SchoolClass(id: "2", name: "Biology", courseCode: "SCI101", gradeLevel: "9"),
            SchoolClass(id: "3", name: "World History", courseCode: "HIST101", gradeLevel: "9"),
            SchoolClass(id: "4", name: "English Literature", courseCode: "ENG101", gradeLevel: "9")
        ]
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.availableClasses = mockClasses
        }
    }
    
    private func createStudent() {
        // Validate form
        guard formIsValid else { return }
        
        isLoading = true
        errorMessage = ""
        
        // Create the student object
        let student = Student()
        student.id = UUID().uuidString
        student.firstName = firstName
        student.lastName = lastName
        student.email = email
        student.grade = grade
        student.studentNumber = studentNumber
        
        // In a real app, you would save this to a backend service
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Set the selected classes
            for classId in self.selectedClasses {
                let enrollment = StudentClassEnrollment()
                enrollment.classId = classId
                enrollment.studentId = student.id
                enrollment.enrollmentDate = Date()
                student.enrollments.append(enrollment)
            }
            
            self.isLoading = false
            
            // Call the completion handler
            self.onComplete(.success(student))
            self.dismiss()
            
            // Or simulate an error (uncomment to test)
            // self.errorMessage = "Failed to create student. Please try again."
            // self.showError = true
        }
    }
}

// Preview provider
struct AddStudentView_Previews: PreviewProvider {
    static var previews: some View {
        AddStudentView { result in
            switch result {
            case .success(let student):
                print("Created student: \(student.firstName) \(student.lastName)")
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}