import SwiftUI

@available(macOS 13.0, iOS 16.0, *)
struct GradebookView: View {
    @EnvironmentObject private var classService: ClassService
    @State private var selectedClass: SchoolClass? = nil
    @State private var selectedAssignment: Assignment? = nil
    @State private var selectedStudent: Student? = nil
    @State private var showingClassPicker = false
    @State private var showingAssignmentPicker = false
    @State private var showingGradeEditor = false
    @State private var isAddingGrade = false
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .nameAscending
    @State private var isLoading = false
    @State private var showingAddGradeSheet = false
    @State private var showingRubricQuickView = false
    @State private var rubricQuickViewAssignment: Assignment? = nil
    @State private var rubricQuickViewStudent: Student? = nil
    
    enum SortOrder: String, CaseIterable {
        case nameAscending = "Name (A-Z)"
        case nameDescending = "Name (Z-A)"
        case gradeAscending = "Grade (Low-High)"
        case gradeDescending = "Grade (High-Low)"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Button("Grade All") {
                    // TODO: Implement bulk grading
                }
                .buttonStyle(.bordered)
                Button("Export CSV") {
                    // TODO: Implement export
                }
                .buttonStyle(.bordered)
                Spacer()
                Picker("Sort", selection: $sortOrder) {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding([.horizontal, .top])
            
            // Main table
            ScrollView([.vertical, .horizontal]) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header row
                    HStack(spacing: 0) {
                        Text("Student")
                            .font(.headline)
                            .frame(width: 160, alignment: .leading)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                        ForEach(assignments, id: \.id) { assignment in
                            HStack(spacing: 4) {
                                Text(assignment.title)
                                    .font(.headline)
                                    .frame(width: 110, alignment: .center)
                                if assignment.rubricId != nil {
                                    Image(systemName: "list.bullet.rectangle")
                                        .foregroundColor(.blue)
                                        .help("Rubric-graded assignment")
                                }
                            }
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .frame(width: 130)
                        }
                    }
                    .background(Color(.systemGray6))
                    
                    // Student rows
                    ForEach(students, id: \.id) { student in
                        HStack(spacing: 0) {
                            Text(student.fullName)
                                .frame(width: 160, alignment: .leading)
                                .padding(.vertical, 8)
                                .background(Color(.systemBackground))
                            ForEach(assignments, id: \.id) { assignment in
                                Button(action: {
                                    if assignment.rubricId != nil {
                                        rubricQuickViewAssignment = assignment
                                        rubricQuickViewStudent = student
                                        showingRubricQuickView = true
                                    } else {
                                        selectedAssignment = assignment
                                        selectedStudent = student
                                        showingGradeEditor = true
                                    }
                                }) {
                                    let (score, level, color) = mockScore(for: student, assignment: assignment)
                                    VStack(spacing: 2) {
                                        if let score = score {
                                            Text("\(score)%")
                                                .fontWeight(.medium)
                                                .foregroundColor(color)
                                        } else {
                                            Text("-")
                                                .foregroundColor(.secondary)
                                        }
                                        if let level = level {
                                            Text("[L\(level)]")
                                                .font(.caption2)
                                                .foregroundColor(color)
                                        }
                                    }
                                    .frame(width: 130, height: 44)
                                    .background(Color(.systemGray5).opacity(0.5))
                                    .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .background(Color(.systemBackground))
                    }
                }
            }
        }
        .sheet(isPresented: $showingRubricQuickView) {
            if let assignment = rubricQuickViewAssignment, let student = rubricQuickViewStudent {
                RubricQuickView(assignment: assignment, student: student)
            }
        }
        .sheet(isPresented: $showingGradeEditor) {
            if let assignment = selectedAssignment, let student = selectedStudent, let classObj = selectedClass {
                GradeEditorView(student: student, assignment: assignment, classInfo: classObj)
            }
        }
    }
    // Mock data for now
    var students: [Student] {
        // Replace with real data
        (1...8).map { i in
            let s = Student()
            s.id = "s\(i)"
            s.firstName = ["Emma", "Liam", "Olivia", "Noah", "Sophia", "Jackson", "Ava", "Lucas"][i-1]
            s.lastName = ["Johnson", "Jones", "Brown", "Smith", "Davis", "Lee", "Garcia", "Martinez"][i-1]
            return s
        }
    }
    var assignments: [Assignment] {
        // Replace with real data
        let a1 = Assignment()
        a1.id = "a1"; a1.title = "Essay 1"; a1.totalPoints = 100; a1.rubricId = "essay_rubric_gr9-10"
        let a2 = Assignment()
        a2.id = "a2"; a2.title = "Lab Report"; a2.totalPoints = 100; a2.rubricId = "lab_report_rubric_gr9-12"
        let a3 = Assignment()
        a3.id = "a3"; a3.title = "Presentation"; a3.totalPoints = 100; a3.rubricId = "presentation_rubric_gr11-12"
        return [a1, a2, a3]
    }
    func mockScore(for student: Student, assignment: Assignment) -> (Int?, Int?, Color) {
        // Mock: random score and level
        let score = Int.random(in: 60...100)
        let level = [1,2,3,4].randomElement()!
        let color: Color =
            score >= 90 ? .green :
            score >= 80 ? .blue :
            score >= 70 ? .yellow :
            score >= 60 ? .orange : .red
        return (score, level, color)
    }
}

struct RubricQuickView: View {
    let assignment: Assignment
    let student: Student
    // For now, show mock rubric breakdown
    var body: some View {
        VStack(spacing: 16) {
            Text("\(student.fullName) - \(assignment.title)")
                .font(.headline)
            Divider()
            VStack(alignment: .leading, spacing: 8) {
                Text("Knowledge/Understanding: Level 3 (Considerable understanding)")
                Text("Thinking/Inquiry: Level 2 (Some use of critical thinking)")
                Text("Communication: Level 3 (Clear and logical)")
                Text("Application: Level 3 (Considerable application)")
            }
            .font(.subheadline)
            Divider()
            Text("Total: 78/100   [L3]")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            Text("Feedback: Great effort! Well organized essay.")
                .font(.body)
                .padding(.top, 8)
            Spacer()
            Button("Close") { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
                .buttonStyle(.bordered)
        }
        .padding()
        .presentationDetents([.medium, .large])
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
