import SwiftUI
import Combine
import Charts

struct AssignmentDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var classService: ClassService
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
    
    enum FeedbackType {
        case success, error
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "exclamationmark.circle.fill"
            }
        }
    }
    
    var assignment: Assignment
    var onDelete: ((Assignment) -> Void)?
    var onDuplicate: ((Assignment) -> Assignment)?
    
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
    
    // Compute submission statistics
    private var submissionCount: Int {
        return assignment.submissions.count
    }
    
    private var gradedCount: Int {
        return assignment.submissions.filter { 
            $0.statusEnum == .graded || $0.statusEnum == .excused 
        }.count
    }
    
    private var lateCount: Int {
        return assignment.submissions.filter { $0.statusEnum == .late }.count
    }
    
    private var completionRate: Double {
        guard let classDetails = classDetails, classDetails.studentCount > 0 else {
            return 0
        }
        return Double(submissionCount) / Double(classDetails.studentCount) * 100
    }
    
    private var averageScore: Double {
        let scoredSubmissions = assignment.submissions.filter { $0.score > 0 }
        guard !scoredSubmissions.isEmpty else { return 0 }
        
        let total = scoredSubmissions.reduce(0) { $0 + Double($1.score) }
        return total / Double(scoredSubmissions.count)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Add top space
                Spacer().frame(height: 10)
                // Status bar
                HStack {
                    Label(assignmentStatus, systemImage: "circle.fill")
                        .foregroundColor(statusColor)
                        .font(.subheadline.bold())
                    
                    Spacer()
                    
                    Text("Due \(dateFormatter.string(from: assignment.dueDate))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // Assignment details
                VStack(alignment: .leading, spacing: 16) {
                    Text("Details")
                        .font(.headline)
                    
                    // Enhanced assignment details with icons
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
                    
                    if !assignment.assignmentDescription.isEmpty {
                        Divider()
                            .padding(.vertical, 4)
                        
                        Text("Description")
                            .font(.headline)
                        
                        Text(assignment.assignmentDescription)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Add file attachments section for demo purposes
                    if true { // Always show sample attachments for demo
                        Divider()
                            .padding(.vertical, 4)
                        
                        Text("Files & Resources")
                            .font(.headline)
                        
                        // Mock attachment files
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
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Class information
                if let schoolClass = classDetails {
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
                            
                            Button {
                                showingCrossClassAssignment = true
                            } label: {
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
                
                // Submission statistics
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Submissions")
                            .font(.headline)
                        
                        Spacer()
                        
                        if assignment.submissions.count > 0 {
                            Button {
                                showingGradeOverview = true
                            } label: {
                                Label("Grade Overview", systemImage: "chart.bar")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                    
                    HStack(spacing: 20) {
                        statView(
                            value: "\(submissionCount)",
                            label: "Submitted",
                            icon: "checkmark.circle.fill",
                            color: .blue
                        )
                        
                        if let classDetails = classDetails, classDetails.studentCount > 0 {
                            let remaining = max(0, classDetails.studentCount - submissionCount)
                            statView(
                                value: "\(remaining)",
                                label: "Missing",
                                icon: "exclamationmark.circle.fill",
                                color: .orange
                            )
                            
                            statView(
                                value: String(format: "%.0f%%", completionRate),
                                label: "Completion",
                                icon: "percent",
                                color: .green
                            )
                        }
                    }
                    .padding(.bottom, 8)
                    
                    if gradedCount > 0 {
                        Divider()
                        
                        HStack(spacing: 20) {
                            statView(
                                value: "\(gradedCount)",
                                label: "Graded",
                                icon: "star.fill",
                                color: .green
                            )
                            
                            statView(
                                value: "\(lateCount)",
                                label: "Late",
                                icon: "clock",
                                color: .orange
                            )
                            
                            statView(
                                value: String(format: "%.1f", averageScore),
                                label: "Avg. Score",
                                icon: "number",
                                color: .blue
                            )
                        }
                        
                        if !assignment.submissions.isEmpty {
                            Text("Grade Distribution")
                                .font(.subheadline.bold())
                                .padding(.top, 4)
                            
                            ScoreDistributionChart(submissions: Array(assignment.submissions))
                                .frame(height: 120)
                                .padding(.top, 4)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Submissions list
                if !assignment.submissions.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Student Submissions")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            // Quick-action buttons
                            HStack {
                                Button {
                                    // Grade all submissions
                                    if let firstSubmission = assignment.submissions.first {
                                        selectedSubmission = firstSubmission
                                        showingSubmissionDetail = true
                                    }
                                } label: {
                                    Label("Grade All", systemImage: "list.bullet.clipboard")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(assignment.submissions.isEmpty)
                                
                                Button {
                                    // Download submissions archive
                                } label: {
                                    Label("Download All", systemImage: "square.and.arrow.down")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .disabled(assignment.submissions.isEmpty)
                            }
                            
                            // List of student submissions
                            ForEach(Array(assignment.submissions)) { submission in
                                SubmissionListRow(submission: submission, onTap: {
                                    selectedSubmission = submission
                                    showingSubmissionDetail = true
                                })
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        showingEdit = true
                    }) {
                        Label("Edit Assignment", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: {
                        if let onDuplicate = onDuplicate {
                            let copy = onDuplicate(assignment)
                            showFeedback(message: "Assignment duplicated", type: .success)
                        }
                    }) {
                        Label("Duplicate", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(role: .destructive, action: {
                        showingDeleteConfirmation = true
                    }) {
                        Label("Delete", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                
                // Learning objectives mastery
                LearningObjectivesMastery()
                
                // Performance comparison
                PerformanceComparisonChart(assignment: assignment)
                
                // Completion trend chart
                CompletionTrendChart(submissions: Array(assignment.submissions))
                
                // Student engagement metrics
                StudentEngagementChart()
            }
            .padding()
        }
        .navigationTitle("Assignment Details")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
        #endif
        .sheet(isPresented: $showingEdit) {
            EditAssignmentView(
                assignment: assignment,
                classes: classService.classes,
                rubrics: RubricLoader.loadAllRubrics(),
                onSave: { updatedAssignment in
                    // Update the assignment in the classService or relevant data store
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
        .sheet(isPresented: $showingGradeOverview) {
            GradeOverviewView(assignment: assignment)
        }
        .sheet(isPresented: $showingSubmissionDetail) {
            if let submission = selectedSubmission {
                NavigationView {
                    SubmissionDetailView(assignment: assignment)
                }
            }
        }
        .sheet(isPresented: $showingCrossClassAssignment) {
            CrossClassAssignmentView(assignment: assignment) { result in
                switch result {
                case .success:
                    showFeedback(message: "Assignment copied to selected classes", type: .success)
                case .failure(let error):
                    showFeedback(message: error.localizedDescription, type: .error)
                }
            }
        }
        .alert("Delete Assignment", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                if let onDelete = onDelete {
                    onDelete(assignment)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this assignment? This action cannot be undone.")
        }
        .overlay(
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
        )
        .onAppear {
            loadClassDetails()
        }
    }
    
    private func detailRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
            
            Spacer()
        }
    }
    
    private func statView(value: String, label: String, icon: String, color: Color) -> some View {
        VStack {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(value)
                    .font(.title2.bold())
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
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
            if self.assignment.submissions.isEmpty {
                print("Debugging: No submissions found, adding mock submissions")
                
                // Add 3 mock submissions
                for i in 0..<3 {
                    let submission = Submission()
                    submission.id = UUID().uuidString
                    submission.studentId = "student\(i+1)"
                    submission.assignmentId = self.assignment.id
                    submission.submittedDate = Date().addingTimeInterval(-1 * Double(i+1) * 3600)
                    submission.statusEnum = .submitted
                    
                    // Add submission to the assignment
                    self.assignment.submissions.append(submission)
                }
                
                print("Debugging: Added \(self.assignment.submissions.count) submissions")
            } else {
                print("Debugging: Found \(self.assignment.submissions.count) submissions")
            }
        }
    }
    
    private func showFeedback(message: String, type: FeedbackType) {
        feedbackMessage = message
        feedbackType = type
        
        withAnimation {
            showingFeedback = true
        }
        
        // Hide after a few seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showingFeedback = false
            }
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
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

// MARK: - Supporting Views

struct SubmissionListRow: View {
    let submission: Submission
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Student \(submission.studentId.suffix(4))") // In a real app, show actual name
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
                        Text("\(submission.score)/\(Int(submission.assignment?.totalPoints ?? 100))")
                            .font(.headline)
                            .foregroundColor(getScoreColor(submission.score))
                    } else {
                        Text(submission.statusEnum == .notSubmitted ? "Missing" : "Needs grading")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Show attachment indicator if there are attachments
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
        let percentage = Double(score) / (submission.assignment?.totalPoints ?? 100) * 100
        switch percentage {
        case 90...100: return .green
        case 80..<90: return .blue
        case 70..<80: return .yellow
        case 60..<70: return .orange
        default: return .red
        }
    }
}

struct ScoreDistributionChart: View {
    let submissions: [Submission]
    
    private let ranges: [Range<Int>] = [
        0..<60,
        60..<70,
        70..<80,
        80..<90,
        90..<101 // Using Range instead of ClosedRange for consistency
    ]
    
    private let rangeColors: [Color] = [
        .red,
        .orange,
        .yellow,
        .blue,
        .green
    ]
    
    private var rangeCounts: [Int] {
        var counts = [Int](repeating: 0, count: ranges.count)
        
        for submission in submissions {
            if submission.statusEnum == .graded {
                let score = submission.score
                let percentage = (Double(score) / (submission.assignment?.totalPoints ?? 100)) * 100
                
                for (i, range) in ranges.enumerated() {
                    if range.contains(Int(percentage)) {
                        counts[i] += 1
                        break
                    }
                }
            }
        }
        
        return counts
    }
    
    var body: some View {
        if #available(iOS 16.0, macOS 13.0, *) {
            Chart {
                ForEach(0..<ranges.count, id: \.self) { i in
                    BarMark(
                        x: .value("Grade Range", rangeLabel(for: i)),
                        y: .value("Count", rangeCounts[i])
                    )
                    .foregroundStyle(rangeColors[i])
                }
            }
        } else {
            // Fallback for older OS versions
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(0..<ranges.count, id: \.self) { i in
                    VStack {
                        Text("\(rangeCounts[i])")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 4)
                            .background(rangeColors[i])
                            .cornerRadius(4)
                            .opacity(rangeCounts[i] > 0 ? 1 : 0)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(rangeColors[i])
                            .frame(height: barHeight(for: rangeCounts[i]))
                        
                        Text(rangeLabel(for: i))
                            .font(.caption2)
                            .rotationEffect(.degrees(-45))
                            .frame(width: 30)
                            .offset(y: 8)
                    }
                }
            }
            .padding(.bottom, 20)
            .padding(.horizontal)
        }
    }
    
    private func barHeight(for count: Int) -> CGFloat {
        let maxCount = rangeCounts.max() ?? 1
        return max(20, CGFloat(count) / CGFloat(maxCount) * 100)
    }
    
    private func rangeLabel(for index: Int) -> String {
        let range = ranges[index]
        if index == ranges.count - 1 {
            // Special handling for the last range (90-100)
            return "\(range.lowerBound)-100"
        } else {
            return "\(range.lowerBound)-\(range.upperBound - 1)"
        }
    }
}

struct GradeOverviewView: View {
    let assignment: Assignment
    @Environment(\.dismiss) var dismiss
    
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
                            statRow(label: "Graded", value: "\(gradedSubmissions.count)")
                            statRow(label: "Average Score", value: String(format: "%.1f", calculateAverageScore()))
                            statRow(label: "Median Score", value: String(format: "%.1f", calculateMedianScore()))
                            statRow(label: "Highest Score", value: String(format: "%.1f", calculateHighestScore()))
                            statRow(label: "Lowest Score", value: String(format: "%.1f", calculateLowestScore()))
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
                        
                        ScoreDistributionChart(submissions: Array(assignment.submissions))
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
    
    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
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

// Add a new struct for tracking assignment completion over time
public struct CompletionTrendChart: View {
    public let submissions: [Submission]
    
    // Generate sample data - in a real app this would use actual submission timestamps
    private var completionData: [(Date, Int)] {
        let calendar = Calendar.current
        var result: [(Date, Int)] = []
        
        // Assume assignment was due 7 days ago for this mock data
        let dueDate = Date().addingTimeInterval(-7 * 86400)
        
        // Create data points for 14 days before due date up to due date
        for day in 0..<14 {
            let date = calendar.date(byAdding: .day, value: -14 + day, to: dueDate)!
            
            // Calculate cumulative submissions by this date
            let submissionsCount = submissions.filter { 
                guard let submittedDate = $0.submittedDate else { return false }
                return submittedDate <= date
            }.count
            
            result.append((date, submissionsCount))
        }
        
        return result
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Completion Trend")
                .font(.headline)
            
            if #available(iOS 16.0, macOS 13.0, *) {
                Chart {
                    ForEach(completionData, id: \.0) { item in
                        LineMark(
                            x: .value("Date", item.0),
                            y: .value("Submissions", item.1)
                        )
                        .foregroundStyle(Color.blue.gradient)
                        .symbol {
                            Circle()
                                .fill(.blue)
                                .frame(width: 6, height: 6)
                        }
                    }
                    
                    // Add a rule mark for the due date
                    RuleMark(x: .value("Due Date", completionData.last!.0))
                        .foregroundStyle(.red)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .annotation(position: .top) {
                            Text("Due Date")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            } else {
                // Fallback for older OS versions
                Text("Completion trend chart available on iOS 16.0+ and macOS 13.0+")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Legend
            HStack(spacing: 16) {
                legendItem(color: .blue, label: "Cumulative Submissions")
                legendItem(color: .red, label: "Due Date")
            }
            .font(.caption)
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    public func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .foregroundColor(.secondary)
        }
    }
    
    public init(submissions: [Submission]) {
        self.submissions = submissions
    }
}

// Add performance comparison chart
public struct PerformanceComparisonChart: View {
    public let assignment: Assignment
    
    // Mock data for class averages - in a real app would come from analytics service
    private var classAverages: [String: Double] = [
        "This Assignment": 82.7,
        "Class Average": 78.5,
        "Previous Quiz": 76.3,
        "Course Average": 81.2
    ]
    
    private var sortedEntries: [(String, Double)] {
        return classAverages.sorted { $0.value > $1.value }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance Comparison")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(sortedEntries, id: \.0) { item in
                    HStack {
                        Text(item.0)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f%%", item.1))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(colorForScore(item.1))
                    }
                    
                    ProgressBar(value: item.1 / 100, color: colorForScore(item.1))
                        .frame(height: 8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    public func colorForScore(_ score: Double) -> Color {
        switch score {
        case 90...100: return .green
        case 80..<90: return .blue
        case 70..<80: return .yellow
        case 60..<70: return .orange
        default: return .red
        }
    }
    
    public init(assignment: Assignment) {
        self.assignment = assignment
    }
}

public struct ProgressBar: View {
    public var value: Double // Between 0 and 1
    public var color: Color = .blue
    
    public var body: some View {
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
    
    public init(value: Double, color: Color = .blue) {
        self.value = value
        self.color = color
    }
}

// Add learning objectives mastery tracking
public struct LearningObjectivesMastery: View {
    // Mock data - in real app would be retrieved from curriculum mapping service
    private let objectives = [
        (objective: "Understand polynomial functions", mastery: 0.85),
        (objective: "Apply quadratic formula", mastery: 0.76),
        (objective: "Graph equations accurately", mastery: 0.92),
        (objective: "Solve word problems", mastery: 0.68)
    ]
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Learning Objectives Mastery")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(objectives, id: \.objective) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.objective)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(Int(item.mastery * 100))%")
                                .font(.subheadline)
                                .foregroundColor(masteryColor(item.mastery))
                        }
                        
                        ProgressBar(value: item.mastery, color: masteryColor(item.mastery))
                            .frame(height: 8)
                    }
                }
            }
            
            // Key
            HStack(spacing: 16) {
                masteryLegendItem(range: "85-100%", color: .green, label: "Mastered")
                masteryLegendItem(range: "70-84%", color: .blue, label: "Proficient")
                masteryLegendItem(range: "< 70%", color: .orange, label: "Developing")
            }
            .font(.caption)
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    public func masteryColor(_ value: Double) -> Color {
        switch value {
        case 0.85...1.0: return .green
        case 0.7..<0.85: return .blue
        default: return .orange
        }
    }
    
    public func masteryLegendItem(range: String, color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                Text(range)
                    .font(.caption2)
            }
            .foregroundColor(.secondary)
        }
    }
    
    public init() {
        // No parameters needed for this demo view
    }
}

// Student engagement metrics visualization
public struct StudentEngagementChart: View {
    // Mock data - would be collected from analytics in a real app
    private let engagementData = [
        (metric: "Avg. Time Spent", value: 28.4, unit: "min", icon: "clock.fill"),
        (metric: "Attempts per Student", value: 1.7, unit: "", icon: "arrow.triangle.2.circlepath"),
        (metric: "Revision Rate", value: 42.0, unit: "%", icon: "pencil"),
        (metric: "Help Requests", value: 5.0, unit: "", icon: "questionmark.circle")
    ]
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Student Engagement")
                .font(.headline)
            
            // Engagement metrics
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(engagementData, id: \.metric) { item in
                    engagementCard(
                        metric: item.metric,
                        value: item.value,
                        unit: item.unit,
                        icon: item.icon
                    )
                }
            }
            
            if #available(iOS 16.0, macOS 13.0, *) {
                timeDistributionChart
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var timeDistributionChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Time Distribution")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.top, 8)
            
            Chart {
                BarMark(
                    x: .value("Range", "< 15 min"),
                    y: .value("Count", 5)
                )
                .foregroundStyle(Color.blue.opacity(0.7))
                
                BarMark(
                    x: .value("Range", "15-30 min"),
                    y: .value("Count", 12)
                )
                .foregroundStyle(Color.blue.opacity(0.8))
                
                BarMark(
                    x: .value("Range", "30-45 min"),
                    y: .value("Count", 8)
                )
                .foregroundStyle(Color.blue.opacity(0.9))
                
                BarMark(
                    x: .value("Range", "> 45 min"),
                    y: .value("Count", 3)
                )
                .foregroundStyle(Color.blue)
            }
            .frame(height: 150)
        }
    }
    
    public func engagementCard(metric: String, value: Double, unit: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.subheadline)
                
                Text(metric)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(String(format: "%.1f", value))
                    .font(.title3)
                    .fontWeight(.bold)
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    public init() {
        // No parameters needed for this demo view
    }
}

// Preview provider
struct AssignmentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AssignmentDetailView(
                assignment: createMockAssignment(),
                onDelete: { _ in },
                onDuplicate: { $0 }
            )
            .environmentObject(ClassService())
        }
    }
    
    // Helper method to create mock data outside of the ViewBuilder context
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
