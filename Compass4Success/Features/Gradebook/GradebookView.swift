import SwiftUI

@available(macOS 13.0, iOS 16.0, *)
struct GradebookView: View {
    @EnvironmentObject private var classService: ClassService
    @State private var selectedClass: SchoolClass?
    @State private var selectedAssignment: Assignment?
    @State private var selectedStudent: Student?
    @State private var showingClassPicker = false
    @State private var showingAssignmentPicker = false
    @State private var showingGradeEditor = false
    @State private var isAddingGrade = false
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .nameAscending
    @State private var isLoading = false
    @State private var showingAddGradeSheet = false
    
    enum SortOrder: String, CaseIterable {
        case nameAscending = "Name (A-Z)"
        case nameDescending = "Name (Z-A)"
        case gradeAscending = "Grade (Low-High)"
        case gradeDescending = "Grade (High-Low)"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Class selector at the top
                classSelectorView
                
                // Main content area - table of grades
                if let selectedClass = selectedClass {
                    if let selectedAssignment = selectedAssignment {
                        // Assignment-specific view
                        assignmentGradesView(for: selectedClass, assignment: selectedAssignment)
                    } else {
                        // Class overview view
                        classGradesOverview(for: selectedClass)
                    }
                } else {
                    // No class selected
                    emptyStateView
                }
            }
            .navigationTitle("Gradebook")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    toolbarContent
                }
            }
        }
        .sheet(isPresented: $showingGradeEditor) {
            if let selectedStudent = selectedStudent, let selectedAssignment = selectedAssignment {
                GradeEditorView(
                    student: selectedStudent,
                    assignment: selectedAssignment,
                    classInfo: selectedClass!
                )
            }
        }
        .onAppear {
            loadClasses()
        }
    }
    
    @ViewBuilder
    private var toolbarContent: some View {
        if selectedClass != nil && selectedAssignment != nil {
            Menu {
                Button(action: {
                    isAddingGrade = true
                    showingGradeEditor = true
                }) {
                    Label("Add Grade", systemImage: "plus")
                }
                
                Button(action: {
                    // Implement CSV export
                }) {
                    Label("Export Grades", systemImage: "square.and.arrow.up")
                }
                
                Button(action: {
                    // Implement grade analysis
                }) {
                    Label("Grade Analysis", systemImage: "chart.bar")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        } else if selectedClass != nil {
            Button(action: {
                showingAssignmentPicker = true
            }) {
                Label("Select Assignment", systemImage: "doc.text.magnifyingglass")
            }
        } else {
            // Empty view for when no class is selected
            EmptyView()
        }
    }
    
    private var classSelectorView: some View {
        VStack {
            Picker("Select Class", selection: $selectedClass) {
                Text("Select a Class").tag(nil as SchoolClass?)
                ForEach(classService.classes) { classItem in
                    Text(classItem.name).tag(classItem as SchoolClass?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .compatibleOnChange(of: selectedClass) { newValue in
                // Reset the selected assignment when class changes
                selectedAssignment = nil
            }
            .padding()
            
            if selectedClass != nil {
                VStack(alignment: .leading) {
                    HStack {
                        if let assignment = selectedAssignment {
                            VStack(alignment: .leading) {
                                Text("Assignment")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(assignment.title)
                                    .font(.headline)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                selectedAssignment = nil
                            }) {
                                Label("Clear", systemImage: "xmark.circle.fill")
                                    .labelStyle(.iconOnly)
                            }
                            .buttonStyle(.borderless)
                        } else {
                            VStack(alignment: .leading) {
                                Text("All Assignments")
                                    .font(.headline)
                                
                                Text(selectedClass?.name ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showingAssignmentPicker = true
                            }) {
                                Label("Select Assignment", systemImage: "doc.text.magnifyingglass")
                                    .font(.subheadline)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Class Selected")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Select a class to view and manage grades")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                showingClassPicker = true
            }) {
                Text("Select Class")
                    .fontWeight(.semibold)
            }
            .buttonStyle(.bordered)
            .padding(.top)
            
            Spacer()
        }
        .padding()
    }
    
    private func classGradesOverview(for classItem: SchoolClass) -> some View {
        VStack {
            SearchBar(text: $searchText, placeholder: "Search students...")
            
            List {
                Section(header: Text("Students")) {
                    ForEach(getMockStudents()) { student in
                        NavigationLink(destination: StudentGradeDetailView(student: student, classItem: classItem)) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.circle")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(student.name)
                                        .font(.headline)
                                    
                                    HStack {
                                        Text("Current Grade: \(mockCurrentGrade(for: student))")
                                            .font(.subheadline)
                                        
                                        if mockGradeDirection(for: student) == "up" {
                                            Image(systemName: "arrow.up")
                                                .foregroundColor(.green)
                                        } else if mockGradeDirection(for: student) == "down" {
                                            Image(systemName: "arrow.down")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text(String(format: "%.1f%%", mockAverageGrade(for: student)))
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(gradeColor(for: mockAverageGrade(for: student)))
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                #if os(iOS)
                .listStyle(InsetGroupedListStyle())
                #else
                .listStyle(DefaultListStyle())
                #endif
            }
        }
    }
    
    private func assignmentGradesView(for classItem: SchoolClass, assignment: Assignment) -> some View {
        VStack {
            SearchBar(text: $searchText, placeholder: "Search students...")
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Due: \(formattedDate(assignment.dueDate))")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Total Points: \(Int(assignment.totalPoints))")
                        .foregroundColor(.secondary)
                }
                
                Divider()
            }
            .padding(.horizontal)
            
            List {
                Section(header: Text("Student Grades")) {
                    ForEach(filteredStudents(in: classItem, for: assignment)) { student in
                        Button(action: {
                            selectedStudent = student
                            isAddingGrade = false
                            showingGradeEditor = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.circle")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(student.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    if let studentGrade = getScoreForStudent(student, assignment: assignment) {
                                        Text("Submitted: \(formattedDate(Date().addingTimeInterval(-Double.random(in: 0...86400))))")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text("Not submitted")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                if let studentGrade = getScoreForStudent(student, assignment: assignment) {
                                    Text("\(Int(studentGrade))/\(Int(assignment.totalPoints))")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(gradeColor(for: (studentGrade / assignment.totalPoints) * 100))
                                } else {
                                    Text("—")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                #if os(iOS)
                .listStyle(InsetGroupedListStyle())
                #else
                .listStyle(DefaultListStyle())
                #endif
            }
        }
    }
    
    // MARK: - Helper Functions
    
    // Mock data and helpers
    private func getMockStudents() -> [Student] {
        let studentNames = [
            "Emma Thompson", "Liam Johnson", "Olivia Davis", "Noah Wilson", 
            "Ava Martinez", "Ethan Anderson", "Sophia Taylor", "Mason Thomas",
            "Isabella Brown", "Logan White", "Mia Harris", "James Martin"
        ]
        
        return studentNames.enumerated().map { index, name in
            let student = Student()
            student.id = "s\(index + 1)"
            student.firstName = name.split(separator: " ").first?.description ?? ""
            student.lastName = name.split(separator: " ").last?.description ?? ""
            return student
        }
    }
    
    private func mockAverageGrade(for student: Student) -> Double {
        // Generate a random but somewhat consistent grade based on student ID
        let idHash = student.id.hash
        return Double.random(in: 60.0...99.0)
    }
    
    private func mockCurrentGrade(for student: Student) -> String {
        let grade = mockAverageGrade(for: student)
        if grade >= 90 {
            return "A"
        } else if grade >= 80 {
            return "B"
        } else if grade >= 70 {
            return "C"
        } else if grade >= 60 {
            return "D"
        } else {
            return "F"
        }
    }
    
    private func mockGradeDirection(for student: Student) -> String {
        let options = ["up", "down", "none"]
        return options.randomElement() ?? "none"
    }
    
    private func mockGradeForAssignment(student: Student, assignment: Assignment) -> Double? {
        // 20% chance of no submission
        if Double.random(in: 0...1) < 0.2 {
            return nil
        }
        
        // Otherwise generate a grade
        return Double.random(in: 60...assignment.totalPoints)
    }
    
    private func gradeColor(for grade: Double) -> Color {
        if grade >= 90 {
            return .green
        } else if grade >= 80 {
            return .blue
        } else if grade >= 70 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func loadClasses() {
        isLoading = true
        // In a real app, this would fetch classes from a service
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
    }
    
    private func filteredStudents(in schoolClass: SchoolClass, for assignment: Assignment) -> [Student] {
        var students = Array(schoolClass.students)
        
        // Apply search filter
        if !searchText.isEmpty {
            students = students.filter { student in
                student.name.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Apply sorting
        switch sortOrder {
        case .nameAscending:
            students.sort { $0.name < $1.name }
        case .nameDescending:
            students.sort { $0.name > $1.name }
        case .gradeAscending:
            students.sort {
                let score1 = getScoreForStudent($0, assignment: assignment) ?? -1
                let score2 = getScoreForStudent($1, assignment: assignment) ?? -1
                return score1 < score2
            }
        case .gradeDescending:
            students.sort {
                let score1 = getScoreForStudent($0, assignment: assignment) ?? -1
                let score2 = getScoreForStudent($1, assignment: assignment) ?? -1
                return score1 > score2
            }
        }
        
        return students
    }
    
    private func getScoreForStudent(_ student: Student, assignment: Assignment) -> Double? {
        if let submission = assignment.submissions.first(where: { $0.studentId == student.id }) {
            return Double(submission.score ?? 0)
        }
        return nil
    }
}

struct StudentGradeDetailView: View {
    let student: Student
    let classItem: SchoolClass
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Student header
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(student.name)
                            .font(.title2)
                            .bold()
                        
                        Text(classItem.name)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Current Grade: A-")
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Grade breakdown
                Text("Grade Breakdown")
                    .font(.title3)
                    .bold()
                    .padding(.top)
                
                ForEach(mockAssignments()) { assignment in
                    assignmentGradeRow(assignment)
                }
            }
            .padding()
        }
        .navigationTitle(student.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    private func assignmentGradeRow(_ assignment: Assignment) -> some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(assignment.title)
                        .font(.headline)
                    
                    Text("Due: \(mockDueDate(for: assignment))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(mockScore(for: assignment)))/ \(Int(assignment.totalPoints))")
                        .font(.headline)
                    
                    Text("\(Int(mockPercentage(for: assignment)))%")
                        .font(.subheadline)
                        .foregroundColor(mockColor(for: assignment))
                }
            }
            
            Divider()
        }
        .padding(.vertical, 4)
    }
    
    // Mock data
    private func mockAssignments() -> [Assignment] {
        return (0..<6).map { i in
            let assignment = Assignment()
            assignment.id = "a\(i)"
            assignment.title = ["Homework \(i+1)", "Quiz \(i+1)", "Project Phase \(i+1)", "Lab Exercise \(i+1)"].randomElement() ?? "Assignment \(i+1)"
            assignment.totalPoints = [10.0, 20.0, 50.0, 100.0].randomElement() ?? 10.0
            return assignment
        }
    }
    
    private func mockDueDate(for assignment: Assignment) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: Date().addingTimeInterval(Double.random(in: -30...30) * 86400))
    }
    
    private func mockScore(for assignment: Assignment) -> Double {
        return Double.random(in: assignment.totalPoints * 0.6...assignment.totalPoints)
    }
    
    private func mockPercentage(for assignment: Assignment) -> Double {
        let score = mockScore(for: assignment)
        return (score / assignment.totalPoints) * 100.0
    }
    
    private func mockColor(for assignment: Assignment) -> Color {
        let percentage = mockPercentage(for: assignment)
        if percentage >= 90 {
            return .green
        } else if percentage >= 80 {
            return .blue
        } else if percentage >= 70 {
            return .orange
        } else {
            return .red
        }
    }
}

@available(macOS 13.0, iOS 16.0, *)
struct GradebookView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GradebookView()
                .environmentObject(ClassService())
        }
    }
}
