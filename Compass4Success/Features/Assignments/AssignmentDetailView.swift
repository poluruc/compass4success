import SwiftUI
import Combine
import Charts

struct AssignmentDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var classService: ClassService
    @StateObject var viewModel: AssignmentViewModel
    
    // State variables
    @State private var showingDeleteConfirmation = false
    @State private var showingCrossClassAssignment = false
    @State private var showingEdit = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var classDetails: SchoolClass?
    @State private var showingFeedback = false
    @State private var feedbackMessage = ""
    @State private var feedbackType: FeedbackType = .success
    @State private var selectedSubmission: Submission?
    @State private var showingSubmissionDetail = false
    @State private var showingGradeOverview = false
    
    // Properties
    var assignment: Assignment
    var onDelete: ((Assignment) -> Void)?
    var onDuplicate: ((Assignment) -> Assignment)?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {                
                // Status section
                AssignmentStatusView(
                    status: assignmentStatus,
                    statusColor: statusColor,
                    dueDate: assignment.dueDate
                )
                
                // Details section
                AssignmentDetailsSection(
                    assignment: assignment,
                    classNameProvider: className(for:)
                )
                
                // Class information
                if let schoolClass = classDetails {
                    ClassInformationSection(
                        schoolClass: schoolClass,
                        onCrossClassAssignment: { showingCrossClassAssignment = true }
                    )
                }
                
                // Submission statistics
                SubmissionStatisticsSection(
                    viewModel: viewModel,
                    classDetails: classDetails,
                    onGradeOverview: { showingGradeOverview = true }
                )
                
                // Submissions list
                if !viewModel.submissions.isEmpty {
                    SubmissionsListSection(
                        submissions: viewModel.submissions,
                        assignment: assignment,
                        onSubmissionSelected: { submission in
                            selectedSubmission = submission
                            showingSubmissionDetail = true
                        },
                        onGradeAll: {
                            if let firstSubmission = viewModel.submissions.first {
                                selectedSubmission = firstSubmission
                                showingSubmissionDetail = true
                            }
                        }
                    )
                }
                
                // Action buttons
                AssignmentActionButtons(
                    onEdit: { showingEdit = true },
                    onDuplicate: {
                        if let onDuplicate = onDuplicate {
                            let copy = onDuplicate(assignment)
                            showFeedback(message: "Assignment duplicated", type: .success)
                        }
                    },
                    onDelete: { showingDeleteConfirmation = true }
                )
                
                // Analytics sections
                AnalyticsSections(
                    assignment: assignment,
                    submissions: Array(viewModel.submissions)
                )
            }
            .padding()
        }
        .navigationTitle("Assignment Details")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        #endif
        .sheet(isPresented: $showingEdit) { editSheet }
        .sheet(isPresented: $showingGradeOverview) { gradeOverviewSheet }
        .sheet(isPresented: $showingSubmissionDetail) { submissionDetailSheet }
        .sheet(isPresented: $showingCrossClassAssignment) { crossClassAssignmentSheet }
        .alert("Delete Assignment", isPresented: $showingDeleteConfirmation) { deleteAlert }
        .overlay { loadingAndFeedbackOverlay }
        .onAppear { loadClassDetails() }
    }
    
    // MARK: - Supporting Views
    
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingEdit = true }) {
                        Label("Edit Assignment", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        if let onDuplicate = onDuplicate {
                            let copy = onDuplicate(assignment)
                            showFeedback(message: "Assignment duplicated", type: .success)
                        }
                    }) {
                        Label("Duplicate", systemImage: "doc.on.doc")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
                        Label("Delete Assignment", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    private var editSheet: some View {
        EditAssignmentView(
            assignment: assignment,
            classes: classService.classes,
            rubrics: RubricLoader.loadAllRubrics(),
            onSave: { updatedAssignment in
                if let classIndex = classService.classes.firstIndex(where: { $0.id == updatedAssignment.classId }) {
                    if let assignmentIndex = classService.classes[classIndex].assignments.firstIndex(where: { $0.id == updatedAssignment.id }) {
                        classService.classes[classIndex].assignments[assignmentIndex] = updatedAssignment
                    }
                }
                showingEdit = false
            },
            onCancel: { showingEdit = false }
        )
    }
    
    private var gradeOverviewSheet: some View {
        GradeOverviewView(assignment: assignmentWithMockGrades)
    }
    
    private var submissionDetailSheet: some View {
        Group {
            if let submission = selectedSubmission,
               let index = viewModel.submissions.firstIndex(where: { $0.id == submission.id }) {
                NavigationView {
                    SubmissionDetailView(
                        viewModel: viewModel,
                        initialSubmissionIndex: index,
                        onSubmissionUpdated: { updatedSubmission in
                            viewModel.updateSubmission(updatedSubmission)
                        }
                    )
                }
            }
        }
    }
    
    private var crossClassAssignmentSheet: some View {
        CrossClassAssignmentView(assignment: assignment) { result in
            switch result {
            case .success:
                showFeedback(message: "Assignment copied to selected classes", type: .success)
            case .failure(let error):
                showFeedback(message: error.localizedDescription, type: .error)
            }
        }
    }
    
    private var deleteAlert: some View {
        Group {
            Button("Delete", role: .destructive) {
                if let onDelete = onDelete {
                    onDelete(assignment)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private var loadingAndFeedbackOverlay: some View {
        ZStack {
            if isLoading {
                Color.black.opacity(0.2)
                    .edgesIgnoringSafeArea(.all)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .padding()
                    .background(Color(.systemBackground).opacity(0.8))
                    .cornerRadius(10)
                    .shadow(radius: 10)
            }
            
            if showingFeedback {
                VStack {
                    Spacer()
                    
                    HStack {
                        Image(systemName: feedbackType.icon)
                        Text(feedbackMessage)
                        Spacer()
                    }
                    .padding()
                    .background(feedbackType.color.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(feedbackType.color)
                    .padding()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: showingFeedback)
    }
    
    // MARK: - Helper Methods
    
    private var assignmentStatus: String {
        if !assignment.isActive {
            return "Completed"
        } else if assignment.dueDate < Date() {
            return "Past Due"
        } else {
            return "Active"
        }
    }
    
    private var statusColor: Color {
        if !assignment.isActive {
            return .gray
        } else if assignment.dueDate < Date() {
            return .red
        } else {
            return .green
        }
    }
    
    private func loadClassDetails() {
        isLoading = true
        
        // In a real app, you would fetch this from a service
        let mockClass = SchoolClass(
            id: assignment.classId ?? UUID().uuidString,
            name: "Algebra I",
            clazzCode: "ALG1",
            courseCode: "MATH101",
            gradeLevel: "9"
        )
        mockClass.studentCount = 28
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.classDetails = mockClass
            self.isLoading = false
            
            // Force UI refresh by recreating the assignment object
            if self.viewModel.submissions.isEmpty {
                self.addMockSubmissions()
            }
        }
    }
    
    private func addMockSubmissions() {
        for i in 0..<3 {
            let submission = Submission()
            submission.id = UUID().uuidString
            submission.studentId = "student\(i+1)"
            submission.assignmentId = self.assignment.id
            submission.submittedDate = Date().addingTimeInterval(-1 * Double(i+1) * 3600)
            submission.statusEnum = .submitted
            self.viewModel.submissions.append(submission)
        }
    }
    
    private func showFeedback(message: String, type: FeedbackType) {
        feedbackMessage = message
        feedbackType = type
        
        withAnimation {
            showingFeedback = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showingFeedback = false
            }
        }
    }
    
    private func className(for classId: String) -> String {
        switch classId {
        case "1": return "Math 9A"
        case "2": return "Science 10B"
        case "3": return "English 11C"
        default: return "Class \(classId)"
        }
    }
}

// MARK: - Supporting View Components

private struct AssignmentStatusView: View {
    let status: String
    let statusColor: Color
    let dueDate: Date
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        HStack {
            Label(status, systemImage: "circle.fill")
                .foregroundColor(statusColor)
                .font(.subheadline.bold())
            
            Spacer()
            
            Text("Due \(dateFormatter.string(from: dueDate))")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

private struct AssignmentDetailsSection: View {
    let assignment: Assignment
    let classNameProvider: (String) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(.headline)
            
            AssignmentPillsView(
                gradeLevels: Array(assignment.gradeLevels),
                classIds: Array(assignment.classIds),
                classNameProvider: classNameProvider
            )
            
            if let rubric = RubricLoader.loadAllRubrics().first(where: { $0.id == assignment.rubricId }) {
                RubricPreviewView(rubric: rubric)
            }
            
            AssignmentInfoGrid(assignment: assignment)
            
            if !assignment.assignmentDescription.isEmpty {
                AssignmentDescriptionView(description: assignment.assignmentDescription)
            }
            
            AssignmentAttachmentsView()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

private struct ClassInformationSection: View {
    let schoolClass: SchoolClass
    let onCrossClassAssignment: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Class")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(schoolClass.name)
                        .font(.body.bold())
                    
                    Text("\(schoolClass.courseCode) • Grade \(schoolClass.gradeLevel)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onCrossClassAssignment) {
                    Text("Assign to Other Classes")
                        .font(.caption)
                }
                .buttonStyle(.borderedProminent)
                #if os(iOS)
                .buttonBorderShape(.capsule)
                #endif
                .controlSize(.small)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

private struct SubmissionStatisticsSection: View {
    @ObservedObject var viewModel: AssignmentViewModel
    let classDetails: SchoolClass?
    let onGradeOverview: () -> Void
    
    private var submissionCount: Int { viewModel.submissions.count }
    private var gradedCount: Int {
        viewModel.submissions.filter { $0.statusEnum == .graded || $0.statusEnum == .excused }.count
    }
    private var lateCount: Int {
        viewModel.submissions.filter { $0.statusEnum == .late }.count
    }
    private var completionRate: Double {
        guard let classDetails = classDetails, classDetails.studentCount > 0 else { return 0 }
        return Double(submissionCount) / Double(classDetails.studentCount) * 100
    }
    private var inProgressCount: Int {
        viewModel.submissions.filter { $0.statusEnum == .submitted || $0.statusEnum == .late }.count - lateCount
    }
    private var missingCount: Int {
        if let classDetails = classDetails, classDetails.studentCount > 0 {
            return max(0, classDetails.studentCount - submissionCount)
        }
        return 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Submissions")
                    .font(.headline)
                
                Spacer()
                
                if viewModel.submissions.count > 0 {
                    Button(action: onGradeOverview) {
                        Label("Grade Overview", systemImage: "chart.bar")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    SubmissionStatView(
                        icon: "checkmark.circle.fill",
                        label: "Submitted",
                        value: submissionCount,
                        color: .blue
                    )
                    SubmissionStatView(
                        icon: "star.fill",
                        label: "Graded",
                        value: gradedCount,
                        color: .green
                    )
                    SubmissionStatView(
                        icon: "clock.fill",
                        label: "Late",
                        value: lateCount,
                        color: .orange
                    )
                    SubmissionStatView(
                        icon: "ellipsis.circle.fill",
                        label: "In Progress",
                        value: inProgressCount,
                        color: .gray
                    )
                    SubmissionStatView(
                        icon: "exclamationmark.circle.fill",
                        label: "Missing",
                        value: missingCount,
                        color: .red
                    )
                    SubmissionStatView(
                        icon: "percent",
                        label: "Completion",
                        value: Int(completionRate),
                        color: .purple,
                        suffix: "%"
                    )
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

private struct SubmissionsListSection: View {
    let submissions: [Submission]
    let assignment: Assignment
    let onSubmissionSelected: (Submission) -> Void
    let onGradeAll: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Student Submissions")
                .font(.headline)
            
            VStack(spacing: 12) {
                HStack {
                    Button(action: onGradeAll) {
                        Label("Grade All", systemImage: "list.bullet.clipboard")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(submissions.isEmpty)
                    
                    Button(action: {}) {
                        Label("Download All", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(submissions.isEmpty)
                }
                
                ForEach(Array(submissions)) { submission in
                    SubmissionListRow(submission: submission, assignment: assignment) {
                        onSubmissionSelected(submission)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

private struct SubmissionListRow: View {
    let submission: Submission
    let assignment: Assignment
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Student \(submission.studentId.suffix(4))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Label(
                            submission.statusEnum.rawValue,
                            systemImage: submission.statusEnum.icon
                        )
                        .font(.caption2)
                        .foregroundColor(submission.statusEnum.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(submission.statusEnum.color.opacity(0.1))
                        .cornerRadius(4)
                        
                        if let submittedDate = submission.submittedDate {
                            Text(formatDate(submittedDate))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    if submission.statusEnum == .graded {
                        Text("\(submission.score)/\(Int(assignment.totalPoints))")
                            .font(.headline)
                            .foregroundColor(getScoreColor(submission.score))
                    } else {
                        Text(submission.statusEnum == .notSubmitted ? "Missing" : "Needs grading")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !submission.attachmentUrls.isEmpty {
                        HStack(spacing: 2) {
                            Image(systemName: "paperclip")
                            Text("\(submission.attachmentUrls.count)")
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func getScoreColor(_ score: Int) -> Color {
        let percentage = Double(score) / (assignment.totalPoints) * 100
        switch percentage {
        case 90...100: return .green
        case 80..<90: return .blue
        case 70..<80: return .yellow
        case 60..<70: return .orange
        default: return .red
        }
    }
}

private struct AssignmentActionButtons: View {
    let onEdit: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: onEdit) {
                Label("Edit Assignment", systemImage: "pencil")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            Button(action: onDuplicate) {
                Label("Duplicate", systemImage: "doc.on.doc")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}

struct AnalyticsSections: View {
    let assignment: Assignment
    let submissions: [Submission]
    
    init(assignment: Assignment, submissions: [Submission]) {
        self.assignment = assignment
        self.submissions = submissions
    }
    
    var body: some View {
        VStack(spacing: 24) {
            LearningObjectivesMastery()
            PerformanceComparisonChart(assignment: assignment)
            CompletionTrendChart(submissions: submissions)
            StudentEngagementChart()
        }
    }
}

// MARK: - Preview Provider
struct AssignmentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let mockAssignment = createMockAssignment()
            AssignmentDetailView(
                viewModel: AssignmentViewModel(assignment: mockAssignment),
                assignment: mockAssignment,
                onDelete: { _ in },
                onDuplicate: { $0 }
            )
            .environmentObject(ClassService())
        }
    }
    
    static func createMockAssignment() -> Assignment {
        let mockAssignment = Assignment()
        mockAssignment.id = "1"
        mockAssignment.title = "Math Quiz"
        mockAssignment.assignmentDescription = "Chapter 5 Quiz covering logarithmic functions"
        mockAssignment.dueDate = Date().addingTimeInterval(86400)
        mockAssignment.assignedDate = Date().addingTimeInterval(-86400)
        mockAssignment.classId = "1"
        mockAssignment.category = AssignmentCategory.quiz.rawValue
        mockAssignment.isActive = true
        mockAssignment.totalPoints = 100
        
        // Force clear any existing submissions
        while !mockAssignment.submissions.isEmpty {
            mockAssignment.submissions.remove(at: 0)
        }
        
        // Create some submissions with explicit submitted status
        for i in 0..<5 {
            let submission = Submission()
            submission.id = UUID().uuidString
            submission.studentId = "student\(i+1)"
            submission.assignmentId = mockAssignment.id
            
            // Mark all as submitted for demonstration
            submission.statusEnum = .submitted
            submission.submittedDate = Date().addingTimeInterval(-1 * Double(i+1) * 3600)
            
            // Add submission to the assignment
            mockAssignment.submissions.append(submission)
        }
        
        print("Preview created assignment with \(mockAssignment.submissions.count) submissions")
        
        // Dump the assignment to debug
        for (index, submission) in mockAssignment.submissions.enumerated() {
            print("Submission \(index+1): ID: \(submission.id), Status: \(submission.statusEnum.rawValue)")
        }
        
        return mockAssignment
    }
}

// MARK: - Supporting View Components

private struct GradeLevelPill: View {
    let grade: String
    
    var body: some View {
        Text("Grade \(grade)")
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.green.opacity(0.15))
            .foregroundColor(.green)
            .cornerRadius(8)
    }
}

private struct ClassPill: View {
    let className: String
    
    var body: some View {
        Text(className)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.purple.opacity(0.15))
            .foregroundColor(.purple)
            .cornerRadius(8)
    }
}

private struct EmptyPill: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.15))
            .foregroundColor(.gray)
            .cornerRadius(8)
    }
}

private struct AssignmentPillsView: View {
    let gradeLevels: [String]
    let classIds: [String]
    let classNameProvider: (String) -> String
    
    var body: some View {
        HStack(spacing: 6) {
            // Grade levels
            if !gradeLevels.isEmpty {
                ForEach(Array(gradeLevels), id: \.self) { grade in
                    GradeLevelPill(grade: grade)
                }
            } else {
                EmptyPill(text: "No Grade Level")
            }
            
            // Classes
            if !classIds.isEmpty {
                ForEach(Array(classIds), id: \.self) { classId in
                    ClassPill(className: classNameProvider(classId))
                }
            } else {
                EmptyPill(text: "No Class Assigned")
            }
        }
    }
}

private struct RubricPreviewView: View {
    let rubric: RubricTemplate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "list.bullet.clipboard")
                    .foregroundColor(.orange)
                Text("Rubric Attached")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
            Text(rubric.title)
                .font(.headline)
            if !rubric.rubricDescription.isEmpty {
                Text(rubric.rubricDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(10)
        .background(Color.orange.opacity(0.08))
        .cornerRadius(10)
    }
}

private struct AssignmentInfoGrid: View {
    let assignment: Assignment
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 12) {
                    enhancedDetailRow(
                        icon: "text.book.closed",
                        iconColor: .blue,
                        label: "Title",
                        value: assignment.title
                    )
                    
                    enhancedDetailRow(
                        icon: "tag",
                        iconColor: .purple,
                        label: "Type",
                        value: assignment.category
                    )
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 12) {
                    enhancedDetailRow(
                        icon: "calendar",
                        iconColor: .green,
                        label: "Assigned",
                        value: dateFormatter.string(from: assignment.assignedDate)
                    )
                    
                    enhancedDetailRow(
                        icon: "number",
                        iconColor: .orange,
                        label: "Points",
                        value: "\(assignment.totalPoints)"
                    )
                }
            }
        }
    }
    
    private func enhancedDetailRow(icon: String, iconColor: Color, label: String, value: String) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(iconColor)
                .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
    }
}

private struct AssignmentDescriptionView: View {
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
                .padding(.vertical, 4)
            
            Text("Description")
                .font(.headline)
            
            Text(description)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

private struct AssignmentAttachmentsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
                .padding(.vertical, 4)
            
            Text("Files & Resources")
                .font(.headline)
            
            VStack(spacing: 8) {
                attachmentRow(
                    icon: "doc.text",
                    name: "Assignment Instructions.pdf",
                    size: "2.4 MB"
                )
                
                attachmentRow(
                    icon: "doc.richtext",
                    name: "Rubric.docx",
                    size: "1.8 MB"
                )
                
                attachmentRow(
                    icon: "link",
                    name: "Online Resource",
                    size: "Web Link"
                )
            }
        }
    }
    
    private func attachmentRow(icon: String, name: String, size: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                
                Text(size)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 18))
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

private struct SubmissionStatView: View {
    let icon: String
    let label: String
    let value: Int
    let color: Color
    var suffix: String = ""
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 18, weight: .bold))
                Text("\(value)\(suffix)")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .background(color.opacity(0.08))
        .cornerRadius(10)
    }
}

// MARK: - Analytics Views

private struct GradeOverviewView: View {
    let assignment: Assignment
    @Environment(\.dismiss) var dismiss
    @State private var selectedBarIndex: Int? = nil
    
    private var gradedSubmissions: [Submission] {
        return assignment.submissions.filter { 
            $0.statusEnum == .graded || $0.statusEnum == .excused 
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Statistics overview
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Grading Statistics")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            statRow(label: "Submissions", value: "\(assignment.submissions.count)")
                            statRow(label: "Graded", value: "\(gradedSubmissions.count)", color: .green)
                            statRow(label: "Average Score", value: String(format: "%.1f", calculateAverageScore()), color: .blue)
                            statRow(label: "Median Score", value: String(format: "%.1f", calculateMedianScore()), color: .purple)
                            statRow(label: "Highest Score", value: String(format: "%.1f", calculateHighestScore()), color: .green)
                            statRow(label: "Lowest Score", value: String(format: "%.1f", calculateLowestScore()), color: .red)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                    
                    // Score distribution chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Score Distribution")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        InteractiveScoreDistributionChart(
                            submissions: Array(assignment.submissions),
                            selectedBarIndex: $selectedBarIndex
                        )
                        .frame(height: 200)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                }
                .padding()
                .navigationTitle("Grade Overview")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private func statRow(label: String, value: String, color: Color? = nil) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color ?? .primary)
        }
    }
    
    private func calculateAverageScore() -> Double {
        let scoredSubmissions = gradedSubmissions.filter { $0.score > 0 }
        guard !scoredSubmissions.isEmpty else { return 0 }
        
        let total = scoredSubmissions.reduce(0) { $0 + Double($1.score) }
        return total / Double(scoredSubmissions.count)
    }
    
    private func calculateMedianScore() -> Double {
        let scores = gradedSubmissions.filter { $0.score > 0 }.map { Double($0.score) }.sorted()
        guard !scores.isEmpty else { return 0 }
        
        if scores.count % 2 == 0 {
            return (scores[scores.count / 2 - 1] + scores[scores.count / 2]) / 2
        } else {
            return scores[scores.count / 2]
        }
    }
    
    private func calculateHighestScore() -> Double {
        return Double(gradedSubmissions.map { $0.score }.max() ?? 0)
    }
    
    private func calculateLowestScore() -> Double {
        let nonZeroScores = gradedSubmissions.filter { $0.score > 0 }.map { $0.score }
        return Double(nonZeroScores.min() ?? 0)
    }
}

private struct InteractiveScoreDistributionChart: View {
    let submissions: [Submission]
    @Binding var selectedBarIndex: Int?
    
    private let ranges: [Range<Int>] = [
        0..<60, 60..<70, 70..<80, 80..<90, 90..<101
    ]
    private let rangeLabels = ["0-59", "60-69", "70-79", "80-89", "90-100"]
    private let rangeColors: [Color] = [
        .red, .orange, .yellow, .blue, .green
    ]
    
    private var rangeCounts: [Int] {
        var counts = [Int](repeating: 0, count: ranges.count)
        for submission in submissions where submission.statusEnum == .graded {
            let score = submission.score
            let percentage = (Double(score) / (submission.assignment?.totalPoints ?? 100)) * 100
            for (i, range) in ranges.enumerated() {
                if range.contains(Int(percentage)) {
                    counts[i] += 1
                    break
                }
            }
        }
        return counts
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(0..<ranges.count, id: \.self) { i in
                    VStack {
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selectedBarIndex == i ? rangeColors[i].opacity(0.7) : rangeColors[i].opacity(0.4))
                                .frame(height: barHeight(for: rangeCounts[i], in: geometry.size.height))
                                .animation(.spring(), value: selectedBarIndex)
                                .onTapGesture {
                                    withAnimation { selectedBarIndex = selectedBarIndex == i ? nil : i }
                                }
                            if selectedBarIndex == i {
                                VStack(spacing: 4) {
                                    Text("\(rangeLabels[i])")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(rangeColors[i])
                                    Text("\(rangeCounts[i]) students")
                                        .font(.caption2)
                                        .foregroundColor(.primary)
                                }
                                .padding(6)
                                .background(Color(.systemBackground).opacity(0.95))
                                .cornerRadius(8)
                                .shadow(radius: 4)
                                .offset(y: -barHeight(for: rangeCounts[i], in: geometry.size.height) - 30)
                            }
                        }
                        Text(rangeLabels[i])
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func barHeight(for count: Int, in availableHeight: CGFloat) -> CGFloat {
        let maxCount = rangeCounts.max() ?? 1
        let minBarHeight: CGFloat = 12
        let maxBarHeight = availableHeight - 40
        if maxCount == 0 { return minBarHeight }
        return max(minBarHeight, CGFloat(count) / CGFloat(maxCount) * maxBarHeight)
    }
}

private struct ProgressBar: View {
    var value: Double // Between 0 and 1
    var color: Color = .blue
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(color)
                    .frame(width: geometry.size.width * CGFloat(min(max(value, 0), 1)))
                    .cornerRadius(4)
            }
        }
    }
}

// Add this computed property to AssignmentDetailView
extension AssignmentDetailView {
    private var assignmentWithMockGrades: Assignment {
        if assignment.submissions.isEmpty {
            let mock = (assignment as Assignment).makeCopy()
            for i in 0..<5 {
                let submission = Submission()
                submission.id = UUID().uuidString
                submission.studentId = "student\(i+1)"
                submission.assignmentId = mock.id
                submission.statusEnum = .graded
                submission.score = [95, 88, 76, 67, 54][i]
                submission.submittedDate = Date().addingTimeInterval(-Double(i) * 3600)
                mock.submissions.append(submission)
            }
            return mock
        }
        return assignment
    }
}
