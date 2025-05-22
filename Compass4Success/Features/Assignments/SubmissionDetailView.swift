import SwiftUI
import Charts
import Foundation

struct SubmissionDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AssignmentViewModel
    @State private var currentSubmissionIndex: Int
    @State private var score: String = ""
    @State private var feedback: String = ""
    @State private var showingAttachmentViewer = false
    @State private var selectedAttachmentURL: String = ""
    @State private var showingRubric = false
    @State private var showingFeedbackTemplate = false
    @State private var isSubmitting = false
    @State private var showingSuccessToast = false
    @State private var successMessage = ""
    @State private var rubricSelections: [String: Int] = [:] // criterion name -> level
    @State private var didSetInitialIndex = false
    let initialSubmissionIndex: Int
    let onSubmissionUpdated: ((Submission) -> Void)?
    private var rubric: RubricTemplate? {
        guard let rubricId = viewModel.assignment.rubricId else { return nil }
        return RubricLoader.loadAllRubrics().first(where: { $0.id == rubricId })
    }
    private var rubricScore: Int {
        guard let rubric = rubric else { return 0 }
        // For simplicity, each criterion is worth equal points
        let totalPoints = Int(viewModel.assignment.totalPoints)
        let pointsPerCriterion = totalPoints / max(1, rubric.criteria.count)
        var total = 0
        for criterion in rubric.criteria {
            if let selectedLevel = rubricSelections[criterion.name],
               let level = criterion.levels.first(where: { $0.level == selectedLevel }) {
                // Ontario: Level 1=50%, 2=65%, 3=80%, 4=100%
                let percent: Double =
                    selectedLevel == 1 ? 0.5 :
                    selectedLevel == 2 ? 0.65 :
                    selectedLevel == 3 ? 0.8 :
                    selectedLevel == 4 ? 1.0 : 0.0
                total += Int(Double(pointsPerCriterion) * percent)
            }
        }
        return total
    }
    
    init(viewModel: AssignmentViewModel, initialSubmissionIndex: Int, onSubmissionUpdated: ((Submission) -> Void)?) {
        self.viewModel = viewModel
        self.initialSubmissionIndex = initialSubmissionIndex
        _currentSubmissionIndex = State(initialValue: initialSubmissionIndex)
        self.onSubmissionUpdated = onSubmissionUpdated
    }
    
    @ViewBuilder
    var body: some View {
        if viewModel.submissions.isEmpty || currentSubmission == nil {
            ProgressView("Loading submission...")
                .onAppear {
                    // Load student info for current submission
                    if let submission = currentSubmission {
                        viewModel.loadStudentInfo(studentId: submission.studentId)
                    }
                }
        } else {
            VStack(spacing: 0) {
                // Top control bar - navigation and quick actions
                topControlBar
                
                // Main content area
                ScrollView {
                    VStack(spacing: 16) {
                        // Student info card
                        studentInfoCard
                        
                        // Submission details
                        submissionDetailsCard
                        
                        // Submission attachments
                        attachmentsSection
                        
                        // Grading section
                        gradingSection
                    }
                    .padding()
                }
                
                // Bottom bar with save, next, previous
                bottomControlBar
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .onAppear {
                // Load student info for current submission
                if let submission = currentSubmission {
                    viewModel.loadStudentInfo(studentId: submission.studentId)
                }
            }
            .onChange(of: viewModel.submissions) { newSubmissions in
                if !newSubmissions.isEmpty {
                    if !didSetInitialIndex, newSubmissions.indices.contains(initialSubmissionIndex) {
                        currentSubmissionIndex = initialSubmissionIndex
                        didSetInitialIndex = true
                    }
                    loadCurrentSubmission()
                }
            }
            .sheet(isPresented: $showingAttachmentViewer) {
                AttachmentViewer(url: selectedAttachmentURL)
            }
            .sheet(isPresented: $showingRubric) {
                RubricScoringView(
                    rubricId: viewModel.assignment.rubricId ?? "",
                    onScoreSelected: { score in
                        self.score = "\(score)"
                        self.showingRubric = false
                    }
                )
            }
            .sheet(isPresented: $showingFeedbackTemplate) {
                FeedbackTemplateSelector(onTemplateSelected: { template in
                    self.feedback = template
                    self.showingFeedbackTemplate = false
                })
            }
            .overlay(
                // Success toast
                Group {
                    if showingSuccessToast {
                        VStack {
                            Spacer()
                            Text(successMessage)
                                .padding()
                                .background(Color.green.opacity(0.9))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.bottom, 20)
                        }
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: showingSuccessToast)
                    }
                }
            )
        }
    }
    
    private var topControlBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.headline)
            }
            .buttonStyle(PressableButtonStyle())
            
            Spacer()
            
            if let student = currentStudent {
                Text("Submission - \(viewModel.assignment.title) by \(student.fullName)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .truncationMode(.middle)
            } else {
                Text("Submission Details")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            Menu {
                if rubric != nil {
                    Button(action: { showingRubric = true }) {
                        Label("Use Rubric", systemImage: "list.bullet.clipboard")
                    }
                }
                
                Button(action: { showingFeedbackTemplate = true }) {
                    Label("Feedback Templates", systemImage: "text.badge.checkmark")
                }
                
                if currentSubmission?.isLate == true {
                    Button(action: { markAsExcused() }) {
                        Label("Mark as Excused", systemImage: "hand.raised")
                    }
                }
                
                Button(action: { resetGrade() }) {
                    Label("Reset Grade", systemImage: "arrow.counterclockwise")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            // Position indicator below the navigation bar
            VStack {
                Spacer()
                if !viewModel.submissions.isEmpty {
                    Text("\(currentSubmissionIndex + 1) of \(viewModel.submissions.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)
                }
            }
        )
    }
    
    private var studentInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let student = currentStudent {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(student.fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("ID: \(student.studentNumber)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Grade \(student.grade)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Student's current course grade
                    if let courseGrade = viewModel.getStudentCourseGrade(student) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Course Grade")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(courseGrade, specifier: "%.1f")%")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(getGradeColor(courseGrade))
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .pressableCard()
            } else {
                Text("No student information available")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
            }
        }
    }
    
    private var submissionDetailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Submission Details")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                if let submission = currentSubmission {
                    detailRow(label: "Status", value: submission.statusEnum.rawValue, color: submission.statusEnum.color)
                    
                    if let submittedDate = submission.submittedDate {
                        detailRow(label: "Submitted", value: formatDate(submittedDate))
                        
                        if submission.isLate {
                            detailRow(label: "Late By", value: formatTimeDifference(submission.submissionAge ?? 0), color: .orange)
                        }
                    }
                    
                    detailRow(label: "Attempts", value: "\(submission.attempts)")
                    
                    if !submission.comments.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Student Comments")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(submission.comments)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                } else {
                    Text("No submission information available")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Attachments")
                .font(.headline)
                .padding(.horizontal)
            
            if let submission = currentSubmission, !submission.attachmentUrls.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(submission.attachmentUrls), id: \.self) { url in
                            Button(action: {
                                selectedAttachmentURL = url
                                showingAttachmentViewer = true
                            }) {
                                AttachmentThumbnail(url: url)
                            }
                            .buttonStyle(PressableButtonStyle())
                        }
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
            } else {
                Text("No attachments provided")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
            }
        }
    }
    
    private var gradingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Grading")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                // Current grade indicator
                if let currentScore = Int(score), currentScore > 0 {
                    HStack {
                        Text("Current Grade:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(currentScore) / \(Int(viewModel.assignment.totalPoints))")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("(\(Int(Double(currentScore) / viewModel.assignment.totalPoints * 100))%)")
                            .font(.subheadline)
                            .foregroundColor(getGradeColor(Double(currentScore) / viewModel.assignment.totalPoints * 100))
                        
                        Spacer()
                        
                        // Grade history button
                        Button(action: { viewModel.showingGradeHistory.toggle() }) {
                            Label("History", systemImage: "clock.arrow.circlepath")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                    .padding(.horizontal)
                }
                
                // Scoring method selector with visual feedback
                if rubric != nil {
                    VStack(spacing: 8) {
                        Picker("Scoring Method", selection: $viewModel.selectedScoringMethod) {
                            Text("Direct Score").tag(ScoringMethod.direct)
                            Text("Rubric").tag(ScoringMethod.rubric)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        // Visual indicator for current method
                        HStack {
                            Image(systemName: viewModel.selectedScoringMethod == .direct ? "pencil.circle.fill" : "list.bullet.clipboard.fill")
                                .foregroundColor(.blue)
                            Text(viewModel.selectedScoringMethod == .direct ? "Enter score directly" : "Score using rubric criteria")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                }
                
                if viewModel.selectedScoringMethod == .rubric, let rubric = rubric {
                    // Rubric-based scoring
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(rubric.criteria) { criterion in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(criterion.name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Spacer()
                                        
                                        // Points indicator
                                        if let selectedLevel = rubricSelections[criterion.name],
                                           let level = criterion.levels.first(where: { $0.level == selectedLevel }) {
                                            let points = calculatePointsForLevel(level.level, totalPoints: Int(viewModel.assignment.totalPoints), criteriaCount: rubric.criteria.count)
                                            Text("\(points) pts")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    // Level selection buttons
                                    HStack(spacing: 12) {
                                        ForEach(criterion.levels, id: \.level) { level in
                                            Button(action: {
                                                withAnimation {
                                                    rubricSelections[criterion.name] = level.level
                                                    score = "\(rubricScore)"
                                                }
                                            }) {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("Level \(level.level)")
                                                        .font(.caption)
                                                        .fontWeight(.medium)
                                                    
                                                    Text(level.description)
                                                        .font(.caption2)
                                                        .foregroundColor(.secondary)
                                                        .lineLimit(2)
                                                        .multilineTextAlignment(.leading)
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding(8)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(rubricSelections[criterion.name] == level.level ? 
                                                              Color.blue.opacity(0.2) : Color(.systemGray6))
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(rubricSelections[criterion.name] == level.level ? 
                                                               Color.blue : Color(.systemGray4), lineWidth: 1)
                                                )
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 400)
                    
                    // Total score summary
                    VStack(spacing: 8) {
                        HStack {
                            Text("Total Rubric Score:")
                                .font(.subheadline)
                            Text("\(rubricScore) / \(Int(viewModel.assignment.totalPoints))")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Text("(\(Int(Double(rubricScore) / viewModel.assignment.totalPoints * 100))%)")
                                .font(.subheadline)
                                .foregroundColor(getGradeColor(Double(rubricScore) / viewModel.assignment.totalPoints * 100))
                        }
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .frame(height: 8)
                                    .cornerRadius(4)
                                
                                Rectangle()
                                    .fill(getGradeColor(Double(rubricScore) / viewModel.assignment.totalPoints * 100))
                                    .frame(width: geometry.size.width * CGFloat(rubricScore) / CGFloat(viewModel.assignment.totalPoints), height: 8)
                                    .cornerRadius(4)
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(.horizontal)
                } else {
                    // Direct score entry with enhanced UI
                    VStack(spacing: 12) {
                        HStack {
                            Text("Score")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(width: 80, alignment: .leading)
                            
                            TextField("Enter score", text: $score)
                                .keyboardType(.decimalPad)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .onChange(of: score) { newValue in
                                    // Validate score is within bounds
                                    if let scoreValue = Int(newValue), scoreValue > Int(viewModel.assignment.totalPoints) {
                                        score = "\(Int(viewModel.assignment.totalPoints))"
                                    }
                                }
                            
                            Text("/ \(Int(viewModel.assignment.totalPoints))")
                                .foregroundColor(.secondary)
                        }
                        
                        // Quick score buttons
                        HStack {
                            ForEach([0, 25, 50, 75, 100], id: \.self) { percentage in
                                Button(action: {
                                    let points = Int(Double(viewModel.assignment.totalPoints) * Double(percentage) / 100.0)
                                    score = "\(points)"
                                }) {
                                    Text("\(percentage)%")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Feedback section with template suggestions
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Feedback")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: { showingFeedbackTemplate = true }) {
                            Label("Templates", systemImage: "text.badge.checkmark")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                    
                    TextEditor(text: $feedback)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        )
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .sheet(isPresented: $viewModel.showingGradeHistory) {
            GradeHistoryView(submission: currentSubmission, viewModel: viewModel)
        }
    }
    
    private var bottomControlBar: some View {
        HStack {
            Button(action: navigateToPrevious) {
                Label("Previous", systemImage: "chevron.left")
                    .padding(.horizontal)
            }
            .disabled(currentSubmissionIndex <= 0 || isSubmitting)
            .buttonStyle(PressableButtonStyle())
            
            Spacer()
            
            Button(action: saveAndStay) {
                if isSubmitting {
                    ProgressView()
                } else {
                    Text("Save")
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                }
            }
            .disabled(isSubmitting)
            .buttonStyle(PressableProminentButtonStyle())
            
            Spacer()
            
            Button(action: saveAndNext) {
                Label("Next", systemImage: "chevron.right")
                    .padding(.horizontal)
            }
            .disabled(currentSubmissionIndex >= viewModel.submissions.count - 1 || isSubmitting)
            .buttonStyle(PressableButtonStyle())
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // Helper views
    private func detailRow(label: String, value: String, color: Color? = nil) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(color)
            
            Spacer()
        }
    }
    
    // Helper functions
    private var currentSubmission: Submission? {
        guard !viewModel.submissions.isEmpty, currentSubmissionIndex < viewModel.submissions.count else {
            return nil
        }
        return viewModel.submissions[currentSubmissionIndex]
    }
    
    private var currentStudent: Student? {
        guard let submission = currentSubmission else { return nil }
        return viewModel.students[submission.studentId]
    }
    
    private func loadCurrentSubmission() {
        guard let submission = currentSubmission else { return }
        score = submission.score > 0 ? "\(submission.score)" : ""
        feedback = submission.comments
        
        // Ensure student data is loaded
        if viewModel.students[submission.studentId] == nil {
            viewModel.loadStudentInfo(studentId: submission.studentId)
        }
    }
    
    private func saveAndStay() {
        saveGrade(moveToNext: false)
    }
    
    private func saveAndNext() {
        saveGrade(moveToNext: true)
    }
    
    private func saveGrade(moveToNext: Bool) {
        guard let submission = currentSubmission else { return }
        isSubmitting = true
        let scoreValue = Int(score) ?? 0
        viewModel.updateSubmissionGrade(
            submission: submission,
            score: scoreValue,
            feedback: feedback
        ) { success in
            isSubmitting = false
            if success {
                showSuccessToast("Grade saved successfully")
                if let updated = viewModel.submissions.first(where: { $0.id == submission.id }) {
                    onSubmissionUpdated?(updated)
                    viewModel.updateSubmission(updated)
                }
                if moveToNext && currentSubmissionIndex < viewModel.submissions.count - 1 {
                    navigateToNext()
                }
            }
        }
    }
    
    private func navigateToNext() {
        if currentSubmissionIndex < viewModel.submissions.count - 1 {
            currentSubmissionIndex += 1
            loadCurrentSubmission()
        }
    }
    
    private func navigateToPrevious() {
        if currentSubmissionIndex > 0 {
            currentSubmissionIndex -= 1
            loadCurrentSubmission()
        }
    }
    
    private func resetGrade() {
        score = ""
        feedback = ""
    }
    
    private func markAsExcused() {
        guard let submission = currentSubmission else { return }
        viewModel.updateSubmissionStatus(submission: submission, status: .excused) { success in
            if success {
                showSuccessToast("Marked as excused")
                if let updated = viewModel.submissions.first(where: { $0.id == submission.id }) {
                    onSubmissionUpdated?(updated)
                    viewModel.updateSubmission(updated)
                }
            }
        }
    }
    
    private func showSuccessToast(_ message: String) {
        successMessage = message
        withAnimation {
            showingSuccessToast = true
        }
        
        // Hide after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showingSuccessToast = false
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatTimeDifference(_ interval: TimeInterval) -> String {
        let hours = Int(interval / 3600)
        if hours > 24 {
            let days = hours / 24
            return "\(days) day\(days == 1 ? "" : "s")"
        } else {
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        }
    }
    
    private func getGradeColor(_ grade: Double) -> Color {
        switch grade {
        case 90...100: return .green
        case 80..<90: return .blue
        case 70..<80: return .yellow
        case 60..<70: return .orange
        default: return .red
        }
    }
    
    // Helper function to calculate points for a rubric level
    private func calculatePointsForLevel(_ level: Int, totalPoints: Int, criteriaCount: Int) -> Int {
        let pointsPerCriterion = totalPoints / max(1, criteriaCount)
        let percentage: Double =
            level == 1 ? 0.5 :
            level == 2 ? 0.65 :
            level == 3 ? 0.8 :
            level == 4 ? 1.0 : 0.0
        return Int(Double(pointsPerCriterion) * percentage)
    }
}

// MARK: - Supporting Views

struct AttachmentThumbnail: View {
    let url: String
    
    var body: some View {
        VStack {
            Image(systemName: getIconForAttachment(url))
                .font(.largeTitle)
                .foregroundColor(.blue)
                .frame(width: 80, height: 80)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            Text(getFileNameFromURL(url))
                .font(.caption)
                .lineLimit(1)
                .frame(width: 80)
        }
    }
    
    private func getIconForAttachment(_ url: String) -> String {
        let ext = URL(string: url)?.pathExtension.lowercased() ?? ""
        
        switch ext {
        case "pdf":
            return "doc.text"
        case "doc", "docx":
            return "doc.richtext"
        case "jpg", "jpeg", "png", "gif", "heic":
            return "photo"
        case "mp4", "mov", "avi":
            return "film"
        case "xls", "xlsx":
            return "tablecells"
        case "ppt", "pptx":
            return "rectangle.3.group"
        default:
            return "doc"
        }
    }
    
    private func getFileNameFromURL(_ url: String) -> String {
        guard let urlObj = URL(string: url) else { return "File" }
        return urlObj.lastPathComponent
    }
}

struct AttachmentViewer: View {
    let url: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Text("Close")
                }
                
                Spacer()
                
                Button(action: { /* Download attachment */ }) {
                    Image(systemName: "square.and.arrow.down")
                }
            }
            .padding()
            
            Spacer()
            
            // This is a placeholder - in a real app, this would render different UIs
            // based on the file type (PDF viewer, image viewer, etc.)
            VStack {
                Image(systemName: "doc.text.viewfinder")
                    .font(.system(size: 72))
                    .foregroundColor(.blue)
                
                Text("Viewing file: \(getFileNameFromURL(url))")
                    .padding()
            }
            
            Spacer()
        }
    }
    
    private func getFileNameFromURL(_ url: String) -> String {
        guard let urlObj = URL(string: url) else { return "File" }
        return urlObj.lastPathComponent
    }
}

struct RubricScoringView: View {
    let rubricId: String
    let onScoreSelected: (Int) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var selectedScores: [String: Int] = [:]
    
    // Mock rubric data - would be fetched from a service
    @State private var rubricItems = [
        RubricItem(id: "1", criterion: "Understanding of Concepts", maxPoints: 25),
        RubricItem(id: "2", criterion: "Application of Knowledge", maxPoints: 25),
        RubricItem(id: "3", criterion: "Critical Thinking", maxPoints: 25),
        RubricItem(id: "4", criterion: "Communication", maxPoints: 25)
    ]
    
    var totalScore: Int {
        selectedScores.values.reduce(0, +)
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(rubricItems) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.criterion)
                            .font(.headline)
                        
                        HStack {
                            ForEach(1...4, id: \.self) { level in
                                let score = calculateScore(level: level, maxPoints: item.maxPoints)
                                let isSelected = selectedScores[item.id] == score
                                
                                Button(action: {
                                    selectedScores[item.id] = score
                                }) {
                                    VStack {
                                        Text("Level \(level)")
                                            .font(.caption)
                                        
                                        Text("\(score)")
                                            .font(.title3)
                                            .fontWeight(isSelected ? .bold : .regular)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    HStack {
                        Text("Total Score")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(totalScore)")
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Rubric Scoring")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        onScoreSelected(totalScore)
                    }
                    .disabled(selectedScores.count < rubricItems.count)
                }
            }
        }
    }
    
    private func calculateScore(level: Int, maxPoints: Int) -> Int {
        let percentage: Double
        
        switch level {
        case 1: percentage = 0.5
        case 2: percentage = 0.65
        case 3: percentage = 0.8
        case 4: percentage = 1.0
        default: percentage = 0.0
        }
        
        return Int(Double(maxPoints) * percentage)
    }
}

struct RubricItem: Identifiable {
    let id: String
    let criterion: String
    let maxPoints: Int
}

struct FeedbackTemplateSelector: View {
    let onTemplateSelected: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    // Mock templates - would be fetched from a service
    let templates = [
        "Excellent work! Your understanding of the concepts is clear and your approach to problem-solving is methodical.",
        "Good job on this assignment. There are a few areas where you could improve, particularly in explaining your reasoning.",
        "You've made a solid attempt, but need to work on understanding the core concepts. Let's schedule time to review.",
        "I see you're struggling with some key concepts. Please come to office hours so we can work through these together.",
        "Outstanding work! Your critical thinking and application of concepts exceed expectations."
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(templates, id: \.self) { template in
                    Button(action: {
                        onTemplateSelected(template)
                    }) {
                        Text(template)
                            .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Feedback Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - View Model

class SubmissionDetailViewModel: ObservableObject {
    @Published var submissions: [Submission] = []
    @Published var students: [String: Student] = [:]
    @Published var courseGrades: [String: Double] = [:]
    @Published var selectedScoringMethod: ScoringMethod = .direct
    @Published var showingGradeHistory = false
    @Published var gradeHistory: [GradeHistoryEntry] = []
    
    func loadSubmissions(for assignment: Assignment) {
        // In a real app, this would filter submissions for the specific assignment
        // and sort them appropriately
        let submissionsToLoad = Array(assignment.submissions)
        
        // Process on a background thread, then update UI on main thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            var processedSubmissions = submissionsToLoad
            
            // Add sample attachments to submissions for UI testing
            for i in 0..<processedSubmissions.count {
                // Add variety of attachment types
                processedSubmissions[i].attachmentUrls.append("https://example.com/homework_\(i).pdf")
                processedSubmissions[i].attachmentUrls.append("https://example.com/image_\(i).jpg")
                
                if i % 2 == 0 {
                    processedSubmissions[i].attachmentUrls.append("https://example.com/document_\(i).docx")
                }
                
                if i % 3 == 0 {
                    processedSubmissions[i].attachmentUrls.append("https://example.com/presentation_\(i).pptx")
                }
            }
            
            // Update on main thread
            DispatchQueue.main.async {
                self.submissions = processedSubmissions
                
                // Load student information for each submission
                for submission in self.submissions {
                    self.loadStudentInfo(studentId: submission.studentId)
                }
                
                // Set initial scoring method based on whether assignment has a rubric
                self.selectedScoringMethod = assignment.rubricId != nil ? .rubric : .direct
            }
        }
    }
    
    func loadStudentInfo(studentId: String) {
        // In a real app, this would fetch from a database
        // For now, create a mock student with proper names
        let student = Student()
        student.id = studentId
        
        // Use proper names instead of generic "Student" names
        let firstNames = ["Emma", "Liam", "Olivia", "Noah", "Sophia", "Jackson", "Ava", "Lucas", "Isabella", "Ethan"]
        let lastNames = ["Johnson", "Smith", "Davis", "Wilson", "Martinez", "Brown", "Garcia", "Rodriguez", "Lopez", "Lee"]
        
        // Use consistent naming based on the student ID to ensure the same student always has the same name
        let nameIndex = abs(studentId.hashValue) % firstNames.count
        student.firstName = firstNames[nameIndex]
        student.lastName = lastNames[(nameIndex + 2) % lastNames.count]
        
        student.studentNumber = "\(Int.random(in: 10000...99999))"
        student.grade = "\(Int.random(in: 9...12))"
        
        // Generate a random course grade
        let courseGrade = Double.random(in: 65...95)
        
        DispatchQueue.main.async {
            self.students[studentId] = student
            self.courseGrades[studentId] = courseGrade
        }
    }
    
    func getStudentCourseGrade(_ student: Student) -> Double? {
        return courseGrades[student.id]
    }
    
    func updateSubmissionGrade(submission: Submission, score: Int, feedback: String, completion: @escaping (Bool) -> Void) {
        // In a real app, this would update the database
        // For the mock, update the local object
        if let index = submissions.firstIndex(where: { $0.id == submission.id }) {
            submissions[index].score = score
            submissions[index].comments = feedback
            submissions[index].statusEnum = .graded
            
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion(true)
            }
        } else {
            completion(false)
        }
    }
    
    func updateSubmissionStatus(submission: Submission, status: CoreSubmissionStatus, completion: @escaping (Bool) -> Void) {
        // In a real app, this would update the database
        if let index = submissions.firstIndex(where: { $0.id == submission.id }) {
            submissions[index].statusEnum = status
            
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion(true)
            }
        } else {
            completion(false)
        }
    }
    
    func loadGradeHistory(for submission: Submission) {
        // In a real app, this would fetch from a database
        // For now, create mock history
        gradeHistory = [
            GradeHistoryEntry(date: Date().addingTimeInterval(-86400), score: 85, feedback: "First submission"),
            GradeHistoryEntry(date: Date().addingTimeInterval(-43200), score: 90, feedback: "Resubmission with improvements")
        ]
    }
}

// MARK: - Preview
struct SubmissionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let mockAssignment: Assignment = {
                let assignment = Assignment()
                assignment.id = "1"
                assignment.title = "Math Quiz"
                assignment.totalPoints = 100
                for i in 0..<5 {
                    let submission = Submission()
                    submission.id = UUID().uuidString
                    submission.studentId = "student\(i)"
                    submission.submittedDate = Date().addingTimeInterval(Double(-i) * 3600)
                    submission.score = Int.random(in: 60...100)
                    submission.statusEnum = i % 3 == 0 ? .submitted : (i % 3 == 1 ? .late : .graded)
                    if i % 2 == 0 {
                        submission.attachmentUrls.append("https://example.com/test.pdf")
                        submission.attachmentUrls.append("https://example.com/image.jpg")
                    }
                    assignment.submissions.append(submission)
                }
                return assignment
            }()
            SubmissionDetailView(
                viewModel: AssignmentViewModel(assignment: mockAssignment),
                initialSubmissionIndex: 0,
                onSubmissionUpdated: nil
            )
        }
    }
}

enum ScoringMethod {
    case direct
    case rubric
}

struct GradeHistoryEntry: Identifiable {
    let id = UUID()
    let date: Date
    let score: Int
    let feedback: String
}

struct GradeHistoryView: View {
    let submission: Submission?
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AssignmentViewModel
    
    var body: some View {
        NavigationView {
            List {
                if let submission = submission {
                    ForEach(viewModel.gradeHistory) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(formatDate(entry.date))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(entry.score) points")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            Text(entry.feedback)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    Text("No grade history available")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Grade History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let submission = submission {
                    viewModel.loadGradeHistory(for: submission)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
} 