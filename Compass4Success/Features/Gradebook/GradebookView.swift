import SwiftUI

struct GradebookView: View {
    @EnvironmentObject private var classService: ClassService
    @State private var selectedClass: SchoolClass?
    @State private var selectedAssignment: Assignment?
    @State private var showingGradeEditor = false
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .nameAscending
    @State private var isLoading = false
    @State private var showingAddGradeSheet = false
    @State private var selectedStudent: Student?
    
    enum SortOrder: String, CaseIterable {
        case nameAscending = "Name (A-Z)"
        case nameDescending = "Name (Z-A)"
        case gradeAscending = "Grade (Low-High)"
        case gradeDescending = "Grade (High-Low)"
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Class selector
                classSelectorView
                
                if let selectedClass = selectedClass {
                    // Assignment selector
                    assignmentSelectorView(for: selectedClass)
                    
                    if let selectedAssignment = selectedAssignment {
                        // Gradebook table
                        gradebookTableView(for: selectedClass, assignment: selectedAssignment)
                    } else {
                        // No assignment selected
                        noAssignmentSelectedView(for: selectedClass)
                    }
                } else {
                    // No class selected
                    noClassSelectedView
                }
            }
            
            if isLoading {
                LoadingOverlay()
            }
        }
        .navigationTitle("Gradebook")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if selectedClass != nil && selectedAssignment != nil {
                    Menu {
                        Button(action: {
                            // Bulk grade entry
                        }) {
                            Label("Bulk Grade Entry", systemImage: "list.bullet")
                        }
                        
                        Button(action: {
                            // Export grades
                        }) {
                            Label("Export Grades", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: {
                            // Grade analytics
                        }) {
                            Label("Grade Analytics", systemImage: "chart.bar")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingGradeEditor) {
            if let selectedClass = selectedClass, let selectedAssignment = selectedAssignment, let selectedStudent = selectedStudent {
                GradeEditorView(
                    student: selectedStudent,
                    assignment: selectedAssignment,
                    classInfo: selectedClass
                )
            }
        }
        .onAppear {
            loadClasses()
        }
    }
    
    private var classSelectorView: some View {
        VStack {
            Picker("Select Class", selection: $selectedClass) {
                Text("Select a class").tag(nil as SchoolClass?)
                
                ForEach(classService.classes) { classItem in
                    Text(classItem.name).tag(classItem as SchoolClass?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedClass) { _, _ in
                // Reset the selected assignment when class changes
                selectedAssignment = nil
            }
            .padding()
            
            Divider()
        }
    }
    
    private func assignmentSelectorView(for schoolClass: SchoolClass) -> some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(schoolClass.assignments)) { assignment in
                        assignmentButton(assignment: assignment)
                    }
                    
                    // Add new assignment button
                    Button(action: {
                        // Action to add new assignment
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Assignment")
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            
            Divider()
        }
    }
    
    private func assignmentButton(assignment: Assignment) -> some View {
        Button(action: {
            withAnimation {
                selectedAssignment = assignment
            }
        }) {
            VStack(alignment: .leading, spacing: 4) {
                Text(assignment.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("\(assignment.totalPoints) points")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedAssignment?.id == assignment.id ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selectedAssignment?.id == assignment.id ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
        .foregroundColor(.primary)
    }
    
    private func gradebookTableView(for schoolClass: SchoolClass, assignment: Assignment) -> some View {
        VStack {
            // Search and sort controls
            HStack {
                SearchBar(text: $searchText, placeholder: "Search students...")
                
                Menu {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Button(action: {
                            sortOrder = order
                        }) {
                            HStack {
                                Text(order.rawValue)
                                if sortOrder == order {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Assignment stats
            assignmentStatsView(for: assignment)
            
            // Student list
            ScrollView {
                LazyVStack(spacing: 1) {
                    // Header row
                    gradeHeaderRow
                    
                    // Student rows
                    ForEach(filteredStudents(in: schoolClass, for: assignment)) { student in
                        studentGradeRow(student: student, assignment: assignment)
                            .onTapGesture {
                                selectedStudent = student
                                showingGradeEditor = true
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
    
    private var gradeHeaderRow: some View {
        HStack {
            Text("Student")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(width: 200, alignment: .leading)
            
            Spacer()
            
            Text("Submission")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(width: 100, alignment: .center)
            
            Text("Grade")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(width: 80, alignment: .center)
            
            Text("Action")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(width: 60, alignment: .center)
        }
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func studentGradeRow(student: Student, assignment: Assignment) -> some View {
        let submission = submissionForStudent(student: student, assignment: assignment)
        
        return HStack {
            // Student info
            HStack(spacing: 12) {
                Text(student.initials)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(getColorForName(student.fullName)))
                
                Text(student.fullName)
                    .font(.body)
                    .lineLimit(1)
            }
            .frame(width: 200, alignment: .leading)
            
            Spacer()
            
            // Submission status
            Text(submission?.statusEnum.rawValue ?? "Not Submitted")
                .font(.subheadline)
                .foregroundColor(submissionStatusColor(submission?.statusEnum))
                .frame(width: 100, alignment: .center)
            
            // Grade
            Text(submission?.formattedScore ?? "—")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 80, alignment: .center)
            
            // Action button
            Button(action: {
                selectedStudent = student
                showingGradeEditor = true
            }) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
                    .frame(width: 60, alignment: .center)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    private func assignmentStatsView(for assignment: Assignment) -> some View {
        HStack(spacing: 20) {
            VStack(alignment: .center) {
                Text("Avg. Score")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(averageScoreForAssignment(assignment))
                    .font(.headline)
            }
            
            Divider().frame(height: 40)
            
            VStack(alignment: .center) {
                Text("Completed")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(completionRateForAssignment(assignment))%")
                    .font(.headline)
            }
            
            Divider().frame(height: 40)
            
            VStack(alignment: .center) {
                Text("Due")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(assignment.formattedDueDate)
                    .font(.headline)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private func noAssignmentSelectedView(for schoolClass: SchoolClass) -> some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "doc.text")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 70)
                .foregroundColor(.gray)
            
            Text("No Assignment Selected")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Select an assignment above to view and manage grades")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            if schoolClass.assignments.isEmpty {
                Button(action: {
                    // Action to add new assignment
                }) {
                    Text("Create First Assignment")
                        .fontWeight(.semibold)
                        .padding()
                        .frame(width: 220)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
            }
            
            Spacer()
        }
    }
    
    private var noClassSelectedView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "book.closed")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 70)
                .foregroundColor(.gray)
            
            Text("No Class Selected")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Select a class from the dropdown above to view its gradebook")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    // Utility methods
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
                student.fullName.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Apply sorting
        switch sortOrder {
        case .nameAscending:
            students.sort { $0.lastName < $1.lastName }
        case .nameDescending:
            students.sort { $0.lastName > $1.lastName }
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
    
    private func submissionForStudent(student: Student, assignment: Assignment) -> AssignmentSubmission? {
        return assignment.submissions.first { $0.studentId == student.id }
    }
    
    private func getScoreForStudent(_ student: Student, assignment: Assignment) -> Int? {
        return submissionForStudent(student: student, assignment: assignment)?.score
    }
    
    private func getColorForName(_ name: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .red, .yellow]
        let hash = abs(name.hashValue) % colors.count
        return colors[hash]
    }
    
    private func submissionStatusColor(_ status: AssignmentSubmission.SubmissionStatus?) -> Color {
        guard let status = status else { return .gray }
        
        switch status {
        case .notSubmitted:
            return .gray
        case .submitted:
            return .blue
        case .late:
            return .orange
        case .graded:
            return .green
        case .excused:
            return .purple
        case .missing:
            return .red
        }
    }
    
    private func averageScoreForAssignment(_ assignment: Assignment) -> String {
        if assignment.submissions.isEmpty {
            return "N/A"
        }
        
        var total = 0
        var count = 0
        
        for submission in assignment.submissions {
            if let score = submission.score {
                total += score
                count += 1
            }
        }
        
        if count == 0 {
            return "N/A"
        }
        
        let average = Double(total) / Double(count)
        return String(format: "%.1f%%", average / Double(assignment.totalPoints) * 100)
    }
    
    private func completionRateForAssignment(_ assignment: Assignment) -> Int {
        if assignment.submissions.isEmpty {
            return 0
        }
        
        let completed = assignment.submissions.filter { $0.statusEnum != .notSubmitted && $0.statusEnum != .missing }.count
        let total = Array(assignment.submissions).count
        
        return Int(Double(completed) / Double(total) * 100)
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .foregroundColor(.primary)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
                .foregroundColor(.white)
        }
    }
}

struct GradebookView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GradebookView()
                .environmentObject(ClassService())
        }
    }
}