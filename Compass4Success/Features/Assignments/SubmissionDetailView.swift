import SwiftUI
import Charts

struct SubmissionDetailView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = SubmissionDetailViewModel()
    @State private var currentSubmissionIndex = 0
    @State private var score: String = ""
    @State private var feedback: String = ""
    @State private var showingAttachmentViewer = false
    @State private var selectedAttachmentURL: String = ""
    @State private var showingRubric = false
    @State private var showingFeedbackTemplate = false
    @State private var isSubmitting = false
    @State private var showingSuccessToast = false
    @State private var successMessage = ""
    
    let assignment: Assignment
    
    var body: some View {
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
            viewModel.loadSubmissions(for: assignment)
            if !viewModel.submissions.isEmpty {
                loadCurrentSubmission()
            }
        }
        .sheet(isPresented: $showingAttachmentViewer) {
            AttachmentViewer(url: selectedAttachmentURL)
        }
        .sheet(isPresented: $showingRubric) {
            RubricScoringView(
                rubricId: assignment.rubricId ?? "",
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
    
    private var topControlBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.headline)
            }
            
            Spacer()
            
            Text("Submission Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Menu {
                Button(action: { showingRubric = true }) {
                    Label("Use Rubric", systemImage: "list.bullet.clipboard")
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
                    
                    Text("/ \(Int(assignment.totalPoints))")
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Feedback")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $feedback)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                HStack {
                    Button(action: { showingRubric = true }) {
                        Label("Use Rubric", systemImage: "list.bullet.clipboard")
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button(action: { showingFeedbackTemplate = true }) {
                        Label("Templates", systemImage: "text.badge.checkmark")
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    private var bottomControlBar: some View {
        HStack {
            Button(action: navigateToPrevious) {
                Label("Previous", systemImage: "chevron.left")
                    .padding(.horizontal)
            }
            .disabled(currentSubmissionIndex <= 0 || isSubmitting)
            
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
            .buttonStyle(.borderedProminent)
            .disabled(isSubmitting)
            
            Spacer()
            
            Button(action: saveAndNext) {
                Label("Next", systemImage: "chevron.right")
                    .padding(.horizontal)
            }
            .disabled(currentSubmissionIndex >= viewModel.submissions.count - 1 || isSubmitting)
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
        score = "\(submission.score)"
        feedback = submission.comments
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
        
        // Parse score as Int
        let scoreValue = Int(score) ?? 0
        
        // Update submission
        viewModel.updateSubmissionGrade(
            submission: submission,
            score: scoreValue,
            feedback: feedback
        ) { success in
            isSubmitting = false
            
            if success {
                showSuccessToast("Grade saved successfully")
                
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
    
    func loadSubmissions(for assignment: Assignment) {
        // In a real app, this would filter submissions for the specific assignment
        // and sort them appropriately
        submissions = Array(assignment.submissions)
        
        // Add sample attachments to submissions for UI testing
        for i in 0..<submissions.count {
            // Add variety of attachment types
            submissions[i].attachmentUrls.append("https://example.com/homework_\(i).pdf")
            submissions[i].attachmentUrls.append("https://example.com/image_\(i).jpg")
            
            if i % 2 == 0 {
                submissions[i].attachmentUrls.append("https://example.com/document_\(i).docx")
            }
            
            if i % 3 == 0 {
                submissions[i].attachmentUrls.append("https://example.com/presentation_\(i).pptx")
            }
        }
        
        // Load student information for each submission
        for submission in submissions {
            loadStudentInfo(studentId: submission.studentId)
        }
    }
    
    func loadStudentInfo(studentId: String) {
        // In a real app, this would fetch from a database
        // For now, create a mock student
        let student = Student()
        student.id = studentId
        student.firstName = "Student"
        student.lastName = "\(Int.random(in: 100...999))"
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
}

// MARK: - Preview
struct SubmissionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let mockAssignment = Assignment()
            mockAssignment.id = "1"
            mockAssignment.title = "Math Quiz"
            mockAssignment.totalPoints = 100
            
            // Create mock submissions
            for i in 0..<5 {
                let submission = Submission()
                submission.id = UUID().uuidString
                submission.studentId = "student\(i)"
                submission.submittedDate = Date().addingTimeInterval(Double(-i) * 3600)
                submission.score = Int.random(in: 60...100)
                submission.statusEnum = i % 3 == 0 ? .submitted : (i % 3 == 1 ? .late : .graded)
                
                // Add mock attachments
                if i % 2 == 0 {
                    submission.attachmentUrls.append("https://example.com/test.pdf")
                    submission.attachmentUrls.append("https://example.com/image.jpg")
                }
                
                mockAssignment.submissions.append(submission)
            }
            
            return SubmissionDetailView(assignment: mockAssignment)
        }
    }
} 