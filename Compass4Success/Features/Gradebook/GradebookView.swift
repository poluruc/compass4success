import SwiftUI

struct GradebookView: View {
    @StateObject private var viewModel = GradebookViewModel()
    @State private var searchText = ""
    @State private var sortOption: SortOption = .nameAZ
    @State private var showExportSheet = false
    @State private var editingCell: GradeCellID? = nil
    @State private var filter: GradebookFilter = .all
    @State private var selectedAssignmentID: String? = nil
    @State private var selectedStudentID: String? = nil
    
    var body: some View {
        // Declare all filter/sort variables at the top
        let filtered = viewModel.filteredStudents(
            search: searchText,
            sort: sortOption,
            filter: filter,
            grades: viewModel.grades
        )
        let studentFiltered = selectedStudentID == nil ? filtered : filtered.filter { $0.id == selectedStudentID }
        let assignmentsToShow = selectedAssignmentID == nil
            ? viewModel.assignments
            : viewModel.assignments.filter { $0.id == selectedAssignmentID }
        VStack(spacing: 0) {
            // Filter bar
            GradebookFilterBar(filter: $filter)
                .padding(.horizontal)
                .padding(.top, 8)
            // Assignment and student pickers
            HStack(spacing: 12) {
                Picker("Assignment", selection: $selectedAssignmentID) {
                    Text("All Assignments").tag(String?.none)
                    ForEach(viewModel.assignments, id: \ .id) { assignment in
                        Text(assignment.title).tag(Optional(assignment.id))
                    }
                }
                .pickerStyle(MenuPickerStyle())
                Spacer()

                Picker("Student", selection: $selectedStudentID) {
                    Text("All Students").tag(String?.none)
                    ForEach(viewModel.students, id: \ .id) { student in
                        Text(student.fullName).tag(Optional(student.id))
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding(.horizontal)
            .padding(.top, 10)
            // .padding(.bottom, 10)

            GradebookToolbar(
                searchText: $searchText,
                sortOption: $sortOption,
                onExport: { showExportSheet = true },
                onGradeAll: viewModel.gradeAll
            )
            .padding(.horizontal)
            .padding(.top)
            
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        // Sticky header row
                        HStack(spacing: 5) {
                            Text("Student")
                                .font(.headline)
                                .frame(width: 160, alignment: .leading)
                                .padding(.vertical, 10)
                                .padding(.leading, 10)
                                .background(Color(.systemGray6))
                                .zIndex(1)
                            Text("Overall")
                                .font(.headline)
                                .frame(width: 80, alignment: .center)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray6))
                                .zIndex(1)
                            ForEach(assignmentsToShow) { assignment in
                                GradebookHeader(assignment: assignment)
                                    .frame(width: 120)
                                    .zIndex(1)
                            }
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(12, corners: [.topLeft, .topRight])
                        .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
                        // Student rows
                        ForEach(Array(studentFiltered.enumerated()), id: \.element.id) { rowIndex, student in
                            HStack(spacing: 5) {
                                NavigationLink(destination: StudentDetailView(student: student), tag: student.id, selection: $selectedStudentID) {
                                    EmptyView()
                                }.frame(width: 0, height: 0).hidden()
                                Button(action: { selectedStudentID = student.id }) {
                                    Text(student.name)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .frame(width: 160, alignment: .leading)
                                        .padding(.vertical, 10)
                                }
                                .buttonStyle(PlainButtonStyle())
                                // .background(Color(.systemBackground))
                                // Overall Grade Cell
                                Group {
                                    if let avg = student.averageGrade {
                                        let color: Color = {
                                            switch avg {
                                            case 90...: return .green
                                            case 75..<90: return .yellow
                                            case 60..<75: return .orange
                                            default: return .red
                                            }
                                        }()
                                        ZStack {
                                            Circle()
                                                .fill(color)
                                                .frame(width: 36, height: 36)
                                            VStack(spacing: 0) {
                                                Text("\(Int(avg))")
                                                    .font(.subheadline).bold()
                                                    .foregroundColor(.white)
                                                Text(letterGrade(for: avg))
                                                    .font(.caption2)
                                                    .foregroundColor(.white.opacity(0.85))
                                            }
                                        }
                                        .frame(width: 80, height: 44, alignment: .center)
                                    } else {
                                        Text("--")
                                            .frame(width: 80, height: 44, alignment: .center)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                ForEach(assignmentsToShow) { assignment in
                                    let cellID = GradeCellID(studentID: student.id, assignmentID: assignment.id)
                                    let grade = viewModel.grades.first { $0.studentId == student.id && $0.assignmentId == assignment.id }
                                    GradebookCell(
                                        grade: grade,
                                        isEditing: editingCell == cellID,
                                        onEdit: { editingCell = cellID },
                                        onSave: { newGrade in
                                            viewModel.updateGrade(cellID: cellID, newScore: newGrade)
                                            editingCell = nil
                                        },
                                        onUpdateComment: { comment in viewModel.updateComment(cellID: cellID, comment: comment) },
                                        onCancel: { editingCell = nil }
                                    )
                                    .frame(width: 120)
                                }
                            }
                            .background(rowIndex % 2 == 0 ? Color(.systemGray6) : Color(.systemGray5))
                            .animation(.easeInOut, value: editingCell)
                        }
                    }
                    .padding(.horizontal, 16)
                    Spacer()
                }
                Spacer()
            }
            Spacer()
        }
        .navigationTitle("Gradebook")
        .sheet(isPresented: $showExportSheet) {
            ExportSheet(grades: viewModel.grades)
        }
    }
}

// MARK: - Toolbar (refactored to two rows)
struct GradebookToolbar: View {
    @Binding var searchText: String
    @Binding var sortOption: SortOption
    var onExport: () -> Void
    var onGradeAll: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search students...", text: $searchText)
                        .appTextFieldStyle()
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                )
                .frame(maxWidth: .infinity)
                Menu {
                    Picker("Sort", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.title).tag(option)
                        }
                    }
                } label: {
                    Label(sortOption.title, systemImage: "arrow.up.arrow.down")
                }
                .frame(maxWidth: 140)
            }
            HStack(spacing: 12) {
                Button(action: onGradeAll) {
                    Label("Grade All", systemImage: "checkmark.seal")
                }
                .buttonStyle(.bordered)
                Spacer()
                Button(action: onExport) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
            }
            .padding(.bottom, 15)
        }
    }
}

// MARK: - Grid
struct GradebookGrid: View {
    let students: [Student]
    let assignments: [Assignment]
    let grades: [Grade]
    @Binding var editingCell: GradeCellID?
    var onEdit: (GradeCellID) -> Void
    var onSave: (GradeCellID, Int) -> Void
    var onUpdateComment: (GradeCellID, String) -> Void

    @State private var selectedStudentID: String? = nil

    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            VStack(spacing: 0) {
                // Sticky header row
                HStack(spacing: 5) {
                    Text("Student")
                        .font(.headline)
                        .frame(width: 160, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.leading, 10)
                        .background(Color(.systemGray6))
                        .zIndex(1)
                    Text("Overall")
                        .font(.headline)
                        .frame(width: 80, alignment: .center)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .zIndex(1)
                    ForEach(assignments) { assignment in
                        GradebookHeader(assignment: assignment)
                            .frame(width: 120)
                            .zIndex(1)
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(12, corners: [.topLeft, .topRight])
                .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)

                // Student rows
                ForEach(Array(students.enumerated()), id: \ .element.id) { rowIndex, student in
                    HStack(spacing: 5) {
                        NavigationLink(destination: StudentDetailView(student: student), tag: student.id, selection: $selectedStudentID) {
                            EmptyView()
                        }.frame(width: 0, height: 0).hidden()
                        Button(action: { selectedStudentID = student.id }) {
                            Text(student.name)
                                .font(.body)
                                .fontWeight(.medium)
                                .frame(width: 160, alignment: .leading)
                                .padding(.vertical, 10)
                                .padding(.leading, 10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .background(Color(.systemBackground))
                        // Overall Grade Cell
                        Group {
                            if let avg = student.averageGrade {
                                let color: Color = {
                                    switch avg {
                                    case 90...: return .green
                                    case 75..<90: return .yellow
                                    case 60..<75: return .orange
                                    default: return .red
                                    }
                                }()
                                ZStack {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 36, height: 36)
                                    VStack(spacing: 0) {
                                        Text("\(Int(avg))")
                                            .font(.subheadline).bold()
                                            .foregroundColor(.white)
                                        Text(letterGrade(for: avg))
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.85))
                                    }
                                }
                                .frame(width: 80, height: 44, alignment: .center)
                            } else {
                                Text("--")
                                    .frame(width: 80, height: 44, alignment: .center)
                                    .foregroundColor(.secondary)
                            }
                        }
                        ForEach(assignments) { assignment in
                            let cellID = GradeCellID(studentID: student.id, assignmentID: assignment.id)
                            let grade = grades.first { $0.studentId == student.id && $0.assignmentId == assignment.id }
                            GradebookCell(
                                grade: grade,
                                isEditing: editingCell == cellID,
                                onEdit: { onEdit(cellID) },
                                onSave: { newGrade in onSave(cellID, newGrade) },
                                onUpdateComment: { comment in onUpdateComment(cellID, comment) },
                                onCancel: { editingCell = nil }
                            )
                            .frame(width: 120)
                        }
                    }
                    .background(rowIndex % 2 == 0 ? Color(.systemGray6) : Color(.systemGray5))
                    .animation(.easeInOut, value: editingCell)
                }
            }
        }
    }
}

// MARK: - Header
struct GradebookHeader: View {
    let assignment: Assignment
    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.blue)
                Text(assignment.title)
                    .font(.headline)
            }
            Text(assignment.dueDate, style: .date)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 120, alignment: .center)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .zIndex(1)
    }
}

// MARK: - Cell
struct GradebookCell: View {
    var grade: Grade?
    var isEditing: Bool
    var onEdit: () -> Void
    var onSave: (Int) -> Void
    var onUpdateComment: (String) -> Void
    var onCancel: () -> Void
    @State private var editValue: String = ""
    @State private var showCommentSheet = false
    @State private var commentText: String = ""
    @State private var wasEditing = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.03), radius: 1, x: 0, y: 1)
            if isEditing {
                HStack(spacing: 4) {
                    TextField("--", text: $editValue)
                        .keyboardType(.numberPad)
                        .frame(width: 44)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        if let val = Int(editValue), val >= 0, val <= 100 {
                            onSave(val)
                        }
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    Button(action: {
                        onCancel()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding(6)
                .onAppear {
                    if !wasEditing {
                        if let grade = grade {
                            editValue = String(Int(grade.percentage))
                        } else {
                            editValue = ""
                        }
                        wasEditing = true
                    }
                }
                .onDisappear {
                    wasEditing = false
                }
            } else {
                HStack(alignment: .center, spacing: 6) {
                    if let grade = grade {
                        Text("\(Int(grade.percentage))")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(gradeColor(for: grade))
                            .clipShape(Circle())
                        // Comment icon always visible, color depends on comment presence
                        Button(action: { showCommentSheet = true; commentText = grade.comments }) {
                            Image(systemName: "bubble.left.fill")
                                .foregroundColor(grade.comments.isEmpty ? .gray : .blue)
                        }
                        // Status icons
                        HStack(spacing: 4) {
                            if grade.isMissing {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                            }
                            if grade.isIncomplete {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text("--")
                            .foregroundColor(.secondary)
                            .frame(width: 36, height: 36)
                        // Always show comment icon, gray if no grade
                        Button(action: { showCommentSheet = true; commentText = "" }) {
                            Image(systemName: "bubble.left.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .frame(height: 44)
        .padding(.vertical, 2)
        .onTapGesture { if !isEditing { onEdit() } }
        .sheet(isPresented: $showCommentSheet) {
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 24) {
                    HStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.blue)
                        Text("Edit Comment")
                            .font(.title2).bold()
                    }
                    .padding(.top, 16)
                    TextField("Enter comment", text: $commentText, axis: .vertical)
                        .font(.body)
                        .padding()
                        .frame(minHeight: 60, maxHeight: 120)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    HStack(spacing: 16) {
                        Button(action: {
                            onUpdateComment(commentText)
                            showCommentSheet = false
                        }) {
                            Label("Save", systemImage: "checkmark.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        Button(action: { showCommentSheet = false }) {
                            Label("Cancel", systemImage: "xmark.circle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.gray)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                )
                .padding(.horizontal, 24)
                Spacer()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }

    func gradeColor(for grade: Grade) -> Color {
        switch grade.percentage {
        case 90...: return .green
        case 75..<90: return .yellow
        case 60..<75: return .orange
        default: return .red
        }
    }
}

// MARK: - Export Sheet (placeholder)
struct ExportSheet: View {
    let grades: [Grade]
    var body: some View {
        VStack(spacing: 20) {
            Text("Export Grades")
                .font(.title2)
            Text("Export to CSV or PDF coming soon!")
                .foregroundColor(.secondary)
            Button("Close") {
                // Dismiss
            }
            .padding()
        }
        .padding()
    }
}

// MARK: - Filter Bar
enum GradebookFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case missing = "Missing"
    case incomplete = "Incomplete"
    var id: String { self.rawValue }
}

struct GradebookFilterBar: View {
    @Binding var filter: GradebookFilter
    @EnvironmentObject var appSettings: AppSettings
    var body: some View {
        HStack(spacing: 12) {
            ForEach(GradebookFilter.allCases) { f in
                Button(action: { filter = f }) {
                    Text(f.rawValue)
                        .fontWeight(filter == f ? .bold : .regular)
                        .foregroundColor(filter == f ? .white : appSettings.accentColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(filter == f ? appSettings.accentColor : Color.clear)
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity)
                }
                .layoutPriority(1)
            }
        }
    }
}

// MARK: - ViewModel & Models
class GradebookViewModel: ObservableObject {
    @Published var students: [Student] = []
    @Published var assignments: [Assignment] = []
    @Published var grades: [Grade] = []
    
    init() {
        let mock = MockDataService.shared.generateMockData()
        self.students = mock.students
        self.assignments = mock.assignments
        // Generate random grades for each student-assignment pair
        var generatedGrades: [Grade] = []
        for student in students {
            for assignment in assignments {
                let randomScore = Double.random(in: 60...100)
                let grade = Grade(studentId: student.id, 
                                assignmentId: assignment.id, 
                                classId: assignment.classId ?? "",
                                score: randomScore,
                                maxScore: 100)
                grade.isMissing = Bool.random() && randomScore < 70
                grade.isIncomplete = Bool.random() && randomScore < 80
                generatedGrades.append(grade)
            }
        }
        // Add sample comments to about half the grades
        let sampleComments = ["Great job!", "Needs improvement", "See me after class", "Excellent work", "Missing explanation", "Check your calculations", "Well done", "Incomplete submission"]
        for i in 0..<generatedGrades.count {
            if i % 2 == 0 {
                generatedGrades[i].comments = sampleComments.randomElement()!
            } else {
                generatedGrades[i].comments = ""
            }
        }
        self.grades = generatedGrades
    }
    
    func filteredStudents(search: String, sort: SortOption, filter: GradebookFilter, grades: [Grade]) -> [Student] {
        var filtered = students
        
        // Apply filter
        if filter != .all {
            let relevantGrades = grades.filter { g in
                switch filter {
                case .missing: return g.isMissing
                case .incomplete: return g.isIncomplete
                case .all: return true
                }
            }
            let relevantStudentIDs = Set(relevantGrades.map { $0.studentId })
            filtered = filtered.filter { student in
                relevantStudentIDs.contains(student.id)
            }
        }
        
        // Apply search
        if !search.isEmpty {
            filtered = filtered.filter { student in
                student.name.lowercased().contains(search.lowercased())
            }
        }
        
        // Apply sort
        switch sort {
        case .nameAZ:
            filtered.sort { $0.name < $1.name }
        case .nameZA:
            filtered.sort { $0.name > $1.name }
        case .overallAsc:
            filtered.sort { ($0.averageGrade ?? -1) < ($1.averageGrade ?? -1) }
        case .overallDesc:
            filtered.sort { ($0.averageGrade ?? -1) > ($1.averageGrade ?? -1) }
        }
        
        return filtered
    }
    
    func filteredGrades(filter: GradebookFilter) -> [Grade] {
        switch filter {
        case .all:
            return grades
        case .missing:
            return grades.filter { $0.isMissing }
        case .incomplete:
            return grades.filter { $0.isIncomplete }
        }
    }
    
    func updateGrade(cellID: GradeCellID, newScore: Int) {
        if let idx = grades.firstIndex(where: { $0.studentId == cellID.studentID && $0.assignmentId == cellID.assignmentID }) {
            grades[idx].score = Double(newScore)
        } else if let assignment = assignments.first(where: { $0.id == cellID.assignmentID }) {
            let grade = Grade(studentId: cellID.studentID,
                            assignmentId: cellID.assignmentID,
                            classId: assignment.classId ?? "",
                            score: Double(newScore))
            grades.append(grade)
        }
    }
    
    func updateComment(cellID: GradeCellID, comment: String) {
        if let idx = grades.firstIndex(where: { $0.studentId == cellID.studentID && $0.assignmentId == cellID.assignmentID }) {
            grades[idx].comments = comment
        } else if let assignment = assignments.first(where: { $0.id == cellID.assignmentID }) {
            let grade = Grade(studentId: cellID.studentID,
                            assignmentId: cellID.assignmentID,
                            classId: assignment.classId ?? "",
                            score: 0.0)
            grade.comments = comment
            grades.append(grade)
        }
    }
    
    func gradeAll() {
        // Example: set all empty grades to 100
        for student in students {
            for assignment in assignments {
                let cellID = GradeCellID(studentID: student.id, assignmentID: assignment.id)
                if !grades.contains(where: { $0.studentId == cellID.studentID && $0.assignmentId == cellID.assignmentID }) {
                    let grade = Grade(studentId: cellID.studentID,
                                    assignmentId: cellID.assignmentID,
                                    classId: assignment.classId ?? "",
                                    score: 100.0)
                    grades.append(grade)
                }
            }
        }
    }
}

struct GradeCellID: Hashable, Equatable {
    let studentID: String
    let assignmentID: String
}

enum SortOption: String, CaseIterable {
    case nameAZ, nameZA, overallAsc, overallDesc
    var title: String {
        switch self {
        case .nameAZ: return "Name (A-Z)"
        case .nameZA: return "Name (Z-A)"
        case .overallAsc: return "Overall Grade (Low-High)"
        case .overallDesc: return "Overall Grade (High-Low)"
        }
    }
}

func colorForGradeStatus(_ status: GradeStatus, _ percentage: Double) -> Color {
    switch status {
    case .graded: return percentage >= 90 ? .green : percentage >= 75 ? .yellow : .orange
    case .missing: return .red
    case .incomplete: return .orange
    case .exempt: return .purple
    default: return .secondary
    }
}

// Helper for corner radius on specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 10.0
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// Helper function for letter grade
private func letterGrade(for percentage: Double) -> String {
    switch percentage {
    case 97...100: return "A+"
    case 93..<97: return "A"
    case 90..<93: return "A-"
    case 87..<90: return "B+"
    case 83..<87: return "B"
    case 80..<83: return "B-"
    case 77..<80: return "C+"
    case 73..<77: return "C"
    case 70..<73: return "C-"
    case 67..<70: return "D+"
    case 63..<67: return "D"
    case 60..<63: return "D-"
    default: return "F"
    }
}

