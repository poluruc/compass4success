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
    @State private var showRubricDetail: Bool = false
    @State private var rubricRefreshTrigger: Int = 0
    @State private var showGradeAllSheet = false
    @State private var selectedTab = 0
    
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
                onGradeAll: { showGradeAllSheet = true }
            )
            .padding(.horizontal)
            .padding(.top)
            
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        // Sticky header row
                        ZStack {
                            Color(.systemGray5)
                                .cornerRadius(12, corners: [.topLeft, .topRight])
                                .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
                            HStack(spacing: 5) {
                                Text("Student")
                                    .font(.headline)
                                    .frame(width: 160, alignment: .leading)
                                    .padding(.vertical, 10)
                                    .padding(.leading, 10)
                                    // .background(Color(.systemGray6))
                                    .zIndex(1)
                                Text("Overall")
                                    .font(.headline)
                                    .frame(width: 80, alignment: .center)
                                    .padding(.vertical, 10)
                                    // .background(Color(.systemGray6))
                                    .zIndex(1)
                                ForEach(assignmentsToShow) { assignment in
                                    NavigationLink(destination: AssignmentDetailView(viewModel: AssignmentViewModel(assignment: assignment), assignment: assignment)) {
                                        GradebookHeader(assignment: assignment)
                                            .frame(width: 160)
                                            .zIndex(1)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(alignment: .leading)
                                    
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
                                        .padding(.leading, 10)
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
                                // Use GradebookGrid for assignments
                                GradebookGrid(
                                    student: student,
                                    assignments: assignmentsToShow,
                                    grades: viewModel.grades,
                                    editingCell: $editingCell,
                                    onEdit: { cellID in editingCell = cellID },
                                    onSave: { cellID, newGrade in viewModel.updateGrade(cellID: cellID, newScore: newGrade); editingCell = nil },
                                    onUpdateComment: { cellID, comment in viewModel.updateComment(cellID: cellID, comment: comment) },
                                    onCancel: { editingCell = nil },
                                    rubricRefreshTrigger: rubricRefreshTrigger,
                                    onRubricSaved: { rubricRefreshTrigger += 1 }
                                )
                            }
                            .padding(.vertical, 2)
                            .padding(.trailing, 10)
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
            ExportOptionsView(
                analyticType: .gradeDistribution, // Use a suitable analyticType or create one for Gradebook
                onExport: { format in
                    // Implement export logic here if needed
                    showExportSheet = false
                }
            )
        }
        .sheet(isPresented: $showGradeAllSheet) {
            GradeAllSheet(
                assignments: viewModel.assignments,
                students: viewModel.students,
                grades: viewModel.grades,
                selectedAssignmentID: selectedAssignmentID,
                onApply: { assignmentID, score in
                    viewModel.gradeAll(for: assignmentID, with: score)
                    showGradeAllSheet = false
                },
                onCancel: { showGradeAllSheet = false }
            )
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
    let student: Student
    let assignments: [Assignment]
    let grades: [Grade]
    @Binding var editingCell: GradeCellID?
    var onEdit: (GradeCellID) -> Void
    var onSave: (GradeCellID, Int) -> Void
    var onUpdateComment: (GradeCellID, String) -> Void
    var onCancel: () -> Void
    var rubricRefreshTrigger: Int
    var onRubricSaved: () -> Void

    var body: some View {
        ForEach(assignments) { assignment in
            let cellID = GradeCellID(studentID: student.id, assignmentID: assignment.id)
            let grade = grades.first { $0.studentId == student.id && $0.assignmentId == assignment.id }
            GradebookCell(
                grade: grade,
                assignment: assignment,
                isEditing: editingCell == cellID,
                onEdit: { onEdit(cellID) },
                onSave: { newGrade in onSave(cellID, newGrade) },
                onUpdateComment: { comment in onUpdateComment(cellID, comment) },
                onCancel: { onCancel() },
                rubricRefreshTrigger: rubricRefreshTrigger,
                onRubricSaved: onRubricSaved
            )
            .padding(.vertical, 2)
            .frame(width: 160, height: 44)
            .frame(maxWidth: .infinity)
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
        .frame(width: 160, alignment: .center)
        .padding(.vertical, 8)
        // .background(Color(.systemGray6))
        .cornerRadius(8)
        .zIndex(1)
    }
}

// MARK: - Cell
struct GradebookCell: View {
    var grade: Grade?
    var assignment: Assignment?
    var isEditing: Bool
    var onEdit: () -> Void
    var onSave: (Int) -> Void
    var onUpdateComment: (String) -> Void
    var onCancel: () -> Void
    var rubricRefreshTrigger: Int
    var onRubricSaved: () -> Void
    
    @State private var editValue: String = ""
    @State private var showCommentSheet = false
    @State private var commentText = ""
    @State private var wasEditing = false
    @State private var showRubricDetail = false
    @State private var showRubricScoring = false
    @FocusState private var isTextFieldFocused: Bool
    
    // Returns the rubric score if available, otherwise nil
    private var rubricScore: (score: Int, max: Int)? {
        guard let grade = grade, let assignment = assignment else { return nil }
        guard let rubricId = assignment.rubricId,
              let rubric = RubricLoader.loadAllRubrics().first(where: { $0.id == rubricId }) else { return nil }
        let total = InMemoryRubricScoreStore.shared.totalScore(for: rubric, studentId: grade.studentId, assignmentId: assignment.id)
        let max = InMemoryRubricScoreStore.shared.maxScore(for: assignment.id)
        if total > 0 { return (total, max) } else { return nil }
    }
    
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
                        .focused($isTextFieldFocused)
                        .onAppear {
                            // Select all text when the field appears
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if let text = editValue as NSString? {
                                    let range = NSRange(location: 0, length: text.length)
                                    if let textField = UIResponder.currentFirstResponder as? UITextField {
                                        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                                    }
                                }
                            }
                        }
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
                        // Focus the text field when editing starts
                        isTextFieldFocused = true
                    }
                }
                .onDisappear {
                    wasEditing = false
                    isTextFieldFocused = false
                }
            } else {
                VStack(spacing: 2) {
                    HStack(alignment: .center, spacing: 6) {
                        // Main score circle
                        let displayScore: Int? = {
                            if let rubricScore = rubricScore {
                                return rubricScore.score > 0 ? rubricScore.score * 100 / max(rubricScore.max, 1) : 0
                            } else if let grade = grade {
                                return Int(grade.percentage)
                            } else {
                                return nil
                            }
                        }()
                        let color: Color = {
                            switch displayScore {
                            case .some(let score):
                                switch score {
                                case 90...: return .green
                                case 75..<90: return .yellow
                                case 60..<75: return .orange
                                default: return .red
                                }
                            case .none:
                                return Color(.systemGray3)
                            }
                        }()
                        ZStack {
                            Circle()
                                .fill(color)
                                .frame(width: 46, height: 36)
                            if let score = displayScore {
                                Text("\(score)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            } else {
                                Text("--")
                                    .font(.headline)
                                    .foregroundColor(Color(.systemGray3))
                            }
                        }
                        // Rubric icon
                        Button(action: { showRubricScoring = true }) {
                            if rubricScore != nil {
                                // Filled icon
                                ZStack {
                                    Circle().fill(Color.blue).frame(width: 24, height: 24)
                                    Text("R")
                                        .font(.caption).bold()
                                        .foregroundColor(.white)
                                }
                            } else {
                                // Outline icon
                                ZStack {
                                    Circle().stroke(Color.blue, lineWidth: 2).frame(width: 24, height: 24)
                                    Text("R")
                                        .font(.caption).bold()
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .help("Score with Rubric")
                        // Comment icon
                        Button(action: { showCommentSheet = true; commentText = grade?.comments ?? "" }) {
                            if let comment = grade?.comments, !comment.isEmpty {
                                Image(systemName: "bubble.left.fill")
                                    .foregroundColor(.blue)
                            } else {
                                Image(systemName: "bubble.left")
                                    .foregroundColor(.blue)
                            }
                        }
                        // Status icons
                        HStack(spacing: 4) {
                            if let grade = grade, grade.isMissing {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                            }
                            if let grade = grade, grade.isIncomplete {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .frame(width: 160, height: 44)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 2)
        .onTapGesture {
            if !isEditing {
                onEdit()
            }
        }
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
                        .frame(minHeight: 60, maxHeight: 120)
                        .appTextFieldStyle( )
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
        // Rubric scoring modal
        .sheet(isPresented: $showRubricScoring) {
            if let assignment = assignment {
                RubricScoringSheet(
                    rubricId: assignment.rubricId ?? "",
                    assignmentId: assignment.id,
                    studentId: grade?.studentId ?? "",
                    onRubricSaved: onRubricSaved
                )
            }
        }
    }
}

// Helper extension to get the current first responder
extension UIResponder {
    private static weak var _currentFirstResponder: UIResponder?
    
    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder._trap), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }
    
    @objc private func _trap() {
        UIResponder._currentFirstResponder = self
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
        self.grades = mock.grades
        // Remove grades for the first 3 students for the first two assignments
        let studentsToRemove = students.prefix(3).map { $0.id }
        let assignmentIDsToRemove = assignments.prefix(2).map { $0.id }
        grades.removeAll { grade in
            studentsToRemove.contains(grade.studentId) && assignmentIDsToRemove.contains(grade.assignmentId)
        }
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
        print("Grading all assignments")
        print("Current grades: \(grades.map { ($0.studentId, $0.assignmentId) })")
        for student in students {
            for assignment in assignments {
                let cellID = GradeCellID(studentID: student.id, assignmentID: assignment.id)
                if let idx = grades.firstIndex(where: { $0.studentId == cellID.studentID && $0.assignmentId == cellID.assignmentID }) {
                    let old = grades[idx]
                    grades[idx] = Grade(studentId: old.studentId, assignmentId: old.assignmentId, classId: old.classId, score: 100.0)
                    print("Updated grade for student: \(cellID.studentID), assignment: \(cellID.assignmentID)")
                } else {
                    let grade = Grade(studentId: cellID.studentID,
                                    assignmentId: cellID.assignmentID,
                                    classId: assignment.classId ?? "",
                                    score: 100.0)
                    grades.append(grade)
                    print("Added grade for student: \(cellID.studentID), assignment: \(cellID.assignmentID)")
                }
            }
        }
    }
    
    func gradeAll(for assignmentID: String) {
        print("Grading all for assignment: \(assignmentID)")
        print("Current grades: \(grades.map { ($0.studentId, $0.assignmentId) })")
        for student in students {
            let cellID = GradeCellID(studentID: student.id, assignmentID: assignmentID)
            if let idx = grades.firstIndex(where: { $0.studentId == cellID.studentID && $0.assignmentId == cellID.assignmentID }) {
                let old = grades[idx]
                grades[idx] = Grade(studentId: old.studentId, assignmentId: old.assignmentId, classId: old.classId, score: 100.0)
                print("Updated grade for student: \(cellID.studentID), assignment: \(cellID.assignmentID)")
            } else {
                let grade = Grade(studentId: cellID.studentID,
                                assignmentId: assignmentID,
                                classId: assignments.first(where: { $0.id == assignmentID })?.classId ?? "",
                                score: 100.0)
                grades.append(grade)
                print("Added grade for student: \(cellID.studentID), assignment: \(cellID.assignmentID)")
            }
        }
    }
    
    func gradeAll(for assignmentID: String, with score: Int) {
        print("Grading all for assignment: \(assignmentID) with score: \(score)")
        
        // Get the set of already graded students for this assignment
        let gradedStudentIDs = Set(grades.filter { $0.assignmentId == assignmentID }.map { $0.studentId })
        
        // Only process students who haven't been graded yet
        let studentsToGrade = students.filter { !gradedStudentIDs.contains($0.id) }
        print("DEBUG: Updating grades for \(studentsToGrade.count) ungraded students")
        
        for student in studentsToGrade {
            print("DEBUG: Processing student: \(student.fullName)")
            let cellID = GradeCellID(studentID: student.id, assignmentID: assignmentID)
            
            // Create new grade for ungraded student
            let grade = Grade(
                studentId: student.id,
                assignmentId: assignmentID,
                classId: assignments.first(where: { $0.id == assignmentID })?.classId ?? "",
                score: Double(score)
            )
            grades.append(grade)
            print("DEBUG: Added grade for student: \(student.fullName), assignment: \(assignmentID), score: \(score)")
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

struct RubricDetailSheet: View {
    var rubricId: String?
    var rubric: RubricTemplate? {
        guard let rubricId = rubricId else { return nil }
        return RubricLoader.loadAllRubrics().first(where: { $0.id == rubricId })
    }
    var body: some View {
        VStack(spacing: 24) {
            if let rubric = rubric {
                Text(rubric.title)
                    .font(.title2).bold()
                if !rubric.rubricDescription.isEmpty {
                    Text(rubric.rubricDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Criterion").font(.headline)
                        Spacer()
                        Text("Level").font(.headline)
                        Spacer()
                        Text("Description").font(.headline)
                    }
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    ForEach(rubric.criteria, id: \ .name) { criterion in
                        RubricCriterionRow(criterion: criterion)
                    }
                }
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(12)
            } else {
                Text("No rubric found for this assignment.")
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button("Close") { UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true) }
                .padding()
        }
        .padding()
    }
}

struct RubricCriterionRow: View {
    let criterion: RubricTemplateCriterion
    // For now, no rubricScore, just show --
    var selectedLevel: Int { 0 } // Replace with actual score if available
    var levelDesc: String {
        criterion.levels.first(where: { $0.level == selectedLevel })?.rubricTemplateLevelDescription ?? "--"
    }
    var body: some View {
        HStack(alignment: .top) {
            Text(criterion.name).font(.body)
            Spacer()
            Text(selectedLevel == 0 ? "--" : "\(selectedLevel)").font(.body).bold()
            Spacer()
            Text(levelDesc).font(.body).foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .background(Color.clear)
        .cornerRadius(6)
    }
}

struct RubricScoringSheet: View {
    var rubricId: String?
    var assignmentId: String?
    var studentId: String?
    var onRubricSaved: (() -> Void)? = nil
    @StateObject private var viewModel = GradebookViewModel()
    @State private var rubricSelections: [String: Int] = [:]
    var rubric: RubricTemplate? {
        guard let rubricId = rubricId else { return nil }
        return RubricLoader.loadAllRubrics().first(where: { $0.id == rubricId })
    }
    var assignment: Assignment? {
        guard let assignmentId = assignmentId else { return nil }
        return viewModel.assignments.first(where: { $0.id == assignmentId })
    }
    // Calculate live score
    private var liveScore: (score: Int, max: Int, percent: Double) {
        guard let rubric = rubric, let assignmentId = assignmentId else { return (0, 0, 0) }
        let total = InMemoryRubricScoreStore.shared.totalScore(
            for: rubric,
            studentId: studentId ?? "",
            assignmentId: assignmentId,
            selections: rubricSelections
        )
        let max = InMemoryRubricScoreStore.shared.maxScore(for: assignmentId)
        let percent = max > 0 ? Double(total) / Double(max) : 0
        return (total, max, percent)
    }
    var body: some View {
        VStack(spacing: 24) {
            if let rubric = rubric {
                Text("Score with Rubric").font(.title2).bold()
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(rubric.criteria, id: \ .name) { criterion in
                        VStack(alignment: .leading, spacing: 8) {
                            // Only show the criterion name once, left-aligned
                            Text(criterion.name)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            // Level selection row, also left-aligned
                            RubricScoringCriterionRow(
                                criterion: criterion,
                                selectedLevel: rubricSelections[criterion.name] ?? 0,
                                onSelect: { level in rubricSelections[criterion.name] = level }
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.bottom, 8)
                    }
                }
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(12)
            } else {
                Text("No rubric found for this assignment.")
                    .foregroundColor(.secondary)
            }
            // Live score display
            if let rubric = rubric {
                let score = liveScore
                let color: Color = {
                    switch score.percent {
                    case 0.9...: return .green
                    case 0.75..<0.9: return .yellow
                    case 0.6..<0.75: return .orange
                    default: return .red
                    }
                }()
                Text("\(score.score)/\(score.max)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(color)
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            Spacer()

            // Save/Cancel row
            HStack {
                Button("Cancel") { UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true) }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Save") {
                    if let assignmentId = assignmentId, let studentId = studentId, let assignment = assignment {
                        InMemoryRubricScoreStore.shared.saveSelections(
                            studentId: studentId,
                            assignmentId: assignmentId,
                            selections: rubricSelections,
                            totalPoints: assignment.totalPoints
                        )
                        onRubricSaved?()
                    }
                    UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            if let assignmentId = assignmentId, let studentId = studentId {
                rubricSelections = InMemoryRubricScoreStore.shared.getSelections(studentId: studentId, assignmentId: assignmentId)
            }
        }
    }
}

struct RubricScoringCriterionRow: View {
    let criterion: RubricTemplateCriterion
    let selectedLevel: Int
    let onSelect: (Int) -> Void
    var levelDesc: String {
        criterion.levels.first(where: { $0.level == selectedLevel })?.rubricTemplateLevelDescription ?? ""
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                ForEach(criterion.levels, id: \ .level) { level in
                    Button(action: { onSelect(level.level) }) {
                        Text("\(level.level)")
                            .frame(width: 32, height: 32)
                            .background(selectedLevel == level.level ? Color.blue : Color(.systemGray4))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .help(level.rubricTemplateLevelDescription)
                }
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            if selectedLevel > 0 {
                Text(levelDesc)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Rubric Mode Picker
struct RubricModePicker: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        Section(header: Text("Mode")) {
            Picker("Mode", selection: $selectedTab) {
                Text("All Students").tag(0)
                Text("Per Student").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

// MARK: - Bulk Rubric Scoring View
struct BulkRubricScoringView: View {
    let rubric: RubricTemplate
    @Binding var bulkRubricSelections: [String: Int]
    let assignmentID: String
    let assignments: [Assignment]
    
    var body: some View {
        Section(header: Text("Bulk Rubric Scoring (applies to all unless overridden)")) {
            ForEach(rubric.criteria, id: \.name) { criterion in
                RubricCriterionPickerView(
                    criterion: criterion,
                    selection: Binding(
                        get: { bulkRubricSelections[criterion.name] ?? 0 },
                        set: { bulkRubricSelections[criterion.name] = $0 }
                    )
                )
            }
            
            if !bulkRubricSelections.isEmpty {
                RubricScoreDisplayView(
                    rubric: rubric,
                    selections: bulkRubricSelections,
                    assignmentID: assignmentID,
                    assignments: assignments
                )
            }
        }
    }
}

// MARK: - Rubric Criterion Picker View
struct RubricCriterionPickerView: View {
    let criterion: RubricTemplateCriterion
    @Binding var selection: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(criterion.name)
                .font(.subheadline)
            Picker("Level", selection: $selection) {
                ForEach(criterion.levels, id: \.level) { level in
                    Text("Level \(level.level)").tag(level.level)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(maxWidth: .infinity)
            
            if let levelObj = criterion.levels.first(where: { $0.level == selection }) {
                Text(levelObj.rubricTemplateLevelDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Rubric Score Display View
struct RubricScoreDisplayView: View {
    let rubric: RubricTemplate
    let selections: [String: Int]
    let assignmentID: String
    let assignments: [Assignment]
    
    private var scoreInfo: (score: Int, total: Int, percent: Double) {
        let totalPoints = Double(assignments.first(where: { $0.id == assignmentID })?.totalPoints ?? 100)
        let criteriaCount = Double(rubric.criteria.count)
        let pointsPerCriterion = totalPoints / max(1.0, criteriaCount)
        let totalScore = rubric.criteria.reduce(0) { sum, criterion in
            let selectedLevel = selections[criterion.name] ?? 0
            let percent: Double = {
                switch selectedLevel {
                case 1: return 0.5
                case 2: return 0.65
                case 3: return 0.8
                case 4: return 1.0
                default: return 0.0
                }
            }()
            return sum + Int(pointsPerCriterion * percent)
        }
        let percent = totalPoints > 0 ? Double(totalScore) / totalPoints : 0.0
        return (score: totalScore, total: Int(totalPoints), percent: percent)
    }
    
    var body: some View {
        let score = scoreInfo
        let color: Color = {
            switch score.percent {
            case 0.9...: return .green
            case 0.75..<0.9: return .yellow
            case 0.6..<0.75: return .orange
            default: return .red
            }
        }()
        
        HStack {
            Spacer()
            Text("\(score.score) / \(score.total)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(color)
                .clipShape(Capsule())
            Spacer()
        }
        .padding(.top, 8)
    }
}

// MARK: - Per Student Rubric View
struct PerStudentRubricView: View {
    let rubric: RubricTemplate
    let ungradedStudents: [Student]
    @Binding var bulkRubricSelections: [String: Int]
    @Binding var perStudentRubricSelections: [String: [String: Int]]
    
    var body: some View {
        Section(header: Text("Per-Student Rubric Overrides")) {
            if ungradedStudents.isEmpty {
                Text("All students graded for this assignment.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(ungradedStudents, id: \.id) { student in
                    StudentRubricOverrideView(
                        student: student,
                        rubric: rubric,
                        bulkSelections: bulkRubricSelections,
                        perStudentSelections: $perStudentRubricSelections
                    )
                }
            }
        }
    }
}

// MARK: - Student Rubric Override View
struct StudentRubricOverrideView: View {
    let student: Student
    let rubric: RubricTemplate
    let bulkSelections: [String: Int]
    @Binding var perStudentSelections: [String: [String: Int]]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(student.fullName)
                .font(.headline)
            ForEach(rubric.criteria, id: \.name) { criterion in
                RubricCriterionPickerView(
                    criterion: criterion,
                    selection: Binding(
                        get: { perStudentSelections[student.id]?[criterion.name] ?? bulkSelections[criterion.name] ?? 0 },
                        set: { newValue in
                            var overrides = perStudentSelections[student.id] ?? bulkSelections
                            overrides[criterion.name] = newValue
                            perStudentSelections[student.id] = overrides
                        }
                    )
                )
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - GradeAllSheet (Refactored)
struct GradeAllSheet: View {
    let assignments: [Assignment]
    let students: [Student]
    let grades: [Grade]
    var selectedAssignmentID: String?
    var onApply: (String, Int) -> Void
    var onCancel: () -> Void
    
    @State private var assignmentID: String = ""
    @State private var scoreText: String = "100"
    @State private var selectedTab = 0
    @State private var bulkRubricSelections: [String: Int] = [:]
    @State private var perStudentRubricSelections: [String: [String: Int]] = [:]
    
    private var rubric: RubricTemplate? {
        guard let assignment = assignments.first(where: { $0.id == assignmentID }),
              let rubricId = assignment.rubricId else { return nil }
        return RubricLoader.loadAllRubrics().first(where: { $0.id == rubricId })
    }
    
    private var ungradedStudents: [Student] {
        let gradedStudentIDs = Set(grades.filter { $0.assignmentId == assignmentID }.map { $0.studentId })
        return students.filter { !gradedStudentIDs.contains($0.id) }
    }
    
    private func updateGradesWithRubric() {
        guard let assignment = assignments.first(where: { $0.id == assignmentID }) else { return }
        
        // Get the set of already graded students for this assignment
        let gradedStudentIDs = Set(grades.filter { $0.assignmentId == assignmentID }.map { $0.studentId })
        
        // Only process students who haven't been graded yet
        let studentsToGrade = students.filter { !gradedStudentIDs.contains($0.id) }
        print("DEBUG: Updating grades for \(studentsToGrade.count) ungraded students")
        
        for student in studentsToGrade {
            print("DEBUG: Processing student: \(student.fullName)")
            // Get the selections for this student (either per-student or bulk)
            let selections = perStudentRubricSelections[student.id] ?? bulkRubricSelections
            
            // Save rubric selections
            InMemoryRubricScoreStore.shared.saveSelections(
                studentId: student.id,
                assignmentId: assignmentID,
                selections: selections,
                totalPoints: assignment.totalPoints
            )
            
            // Calculate and update the actual grade
            if let rubric = rubric {
                let totalScore = InMemoryRubricScoreStore.shared.totalScore(
                    for: rubric,
                    studentId: student.id,
                    assignmentId: assignmentID,
                    selections: selections
                )
                let maxScore = InMemoryRubricScoreStore.shared.maxScore(for: assignmentID)
                let percentage = maxScore > 0 ? Double(totalScore) * 100.0 / Double(maxScore) : 0.0
                
                print("DEBUG: Setting grade for \(student.fullName) to \(percentage)%")
                // Update the grade in the gradebook
                onApply(assignmentID, Int(percentage))
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Assignment")) {
                    Picker("Assignment", selection: $assignmentID) {
                        ForEach(assignments, id: \.id) { assignment in
                            Text(assignment.title).tag(assignment.id)
                        }
                    }
                }
                
                if let rubric = rubric {
                    RubricModePicker(selectedTab: $selectedTab)
                    
                    if selectedTab == 0 {
                        BulkRubricScoringView(
                            rubric: rubric,
                            bulkRubricSelections: $bulkRubricSelections,
                            assignmentID: assignmentID,
                            assignments: assignments
                        )
                    } else {
                        PerStudentRubricView(
                            rubric: rubric,
                            ungradedStudents: ungradedStudents,
                            bulkRubricSelections: $bulkRubricSelections,
                            perStudentRubricSelections: $perStudentRubricSelections
                        )
                    }
                } else {
                    Section(header: Text("Score for All")) {
                        TextField("Score", text: $scoreText)
                            .keyboardType(.numberPad)
                    }
                    
                    Section(header: Text("Ungraded Students")) {
                        if ungradedStudents.isEmpty {
                            Text("All students graded for this assignment.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(ungradedStudents, id: \.id) { student in
                                Text(student.fullName)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Grade All")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        if let rubric = rubric {
                            updateGradesWithRubric()
                            onCancel()
                        } else if let score = Int(scoreText), !assignmentID.isEmpty {
                            onApply(assignmentID, score)
                            onCancel()
                        }
                    }
                    .disabled(assignmentID.isEmpty || (rubric == nil && Int(scoreText) == nil))
                }
            }
            .onAppear {
                if let selected = selectedAssignmentID {
                    assignmentID = selected
                } else if let first = assignments.first?.id {
                    assignmentID = first
                }
                
                if let rubric = rubric {
                    for criterion in rubric.criteria {
                        if bulkRubricSelections[criterion.name] == nil {
                            bulkRubricSelections[criterion.name] = 0
                        }
                    }
                }
            }
        }
    }
}

