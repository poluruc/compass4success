import Foundation
import RealmSwift
import SwiftUI
// Import needed for RubricScore definition, used in line 54
// We're resolving the ambiguous reference error

// Model representing a student's submission for an assignment
public class Submission: Object, Identifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted var assignmentId: String = ""
    @Persisted var studentId: String = ""
    @Persisted var submittedDate: Date?
    @Persisted var status: String = CoreSubmissionStatus.notSubmitted.rawValue
    @Persisted var attachmentUrls = List<String>()
    @Persisted var comments: String = ""
    @Persisted var feedbackRequestFlag: Bool = false
    @Persisted var draft: Bool = false
    @Persisted var attempts: Int = 0
    @Persisted var score: Int = 0
    @Persisted var rubricScoreId: String?
    @Persisted var feedback: String = ""  // Teacher feedback
    @Persisted var graderNotes: String = "" // Private notes for the teacher
    @Persisted var gradedDate: Date?
    @Persisted var gradedBy: String = "" // Teacher ID
    
    // Computed property for the status as an enum
    var statusEnum: CoreSubmissionStatus {
        get {
            return CoreSubmissionStatus(rawValue: status) ?? .notSubmitted
        }
        set {
            status = newValue.rawValue
        }
    }
    
    // Reference to the corresponding assignment (transient)
    var assignment: Assignment? {
        return getAssignment()
    }
    
    // Computed property for whether the submission is late
    var isLate: Bool {
        guard let assignment = getAssignment() else { return false }
        guard let submittedDate = submittedDate else { return false }
        
        return submittedDate > assignment.dueDate
    }
    
    // Computed property for submission age
    var submissionAge: TimeInterval? {
        guard let submittedDate = submittedDate else { return nil }
        return Date().timeIntervalSince(submittedDate)
    }
    
    // Reference to associated rubric score (if any)
    // Using a function to avoid ambiguous type reference
    func getRubricScore() -> Any? {
        guard let _ = rubricScoreId else { return nil }
        // In a real app, this would fetch from the database
        return nil
    }
    
    // Computed property for score as percentage
    var scorePercentage: Double {
        guard let assignment = getAssignment(), assignment.totalPoints > 0 else {
            return 0
        }
        return Double(score) / assignment.totalPoints * 100
    }
    
    // Computed property for letter grade
    var letterGrade: String {
        let percentage = scorePercentage
        switch percentage {
        case 90...100: return "A+"
        case 85..<90: return "A"
        case 80..<85: return "A-"
        case 77..<80: return "B+"
        case 73..<77: return "B"
        case 70..<73: return "B-"
        case 67..<70: return "C+"
        case 63..<67: return "C"
        case 60..<63: return "C-"
        case 57..<60: return "D+"
        case 53..<57: return "D"
        case 50..<53: return "D-"
        default: return "F"
        }
    }
    
    // Convenience initializer
    convenience init(assignmentId: String, studentId: String, submittedDate: Date? = nil, status: CoreSubmissionStatus = .notSubmitted) {
        self.init()
        self.assignmentId = assignmentId
        self.studentId = studentId
        self.submittedDate = submittedDate
        self.statusEnum = status
    }
    
    // Helper method to get the assignment (placeholder implementation)
    private func getAssignment() -> Assignment? {
        // In a real-world app, this would query the database
        // For now, create a mock Assignment to prevent nil issues
        let assignment = Assignment()
        assignment.id = assignmentId
        assignment.title = "Mock Assignment"
        assignment.totalPoints = 100
        assignment.dueDate = Date()
        assignment.isActive = true
        return assignment
    }
    
    // Add an attachment URL
    func addAttachment(_ url: String) {
        attachmentUrls.append(url)
    }
    
    // Submit the assignment
    func submit() {
        statusEnum = .submitted
        submittedDate = Date()
        attempts += 1
        draft = false
    }
    
    // Grade the submission
    func grade(score: Int, feedback: String, gradedBy: String) {
        self.score = score
        self.feedback = feedback
        self.gradedBy = gradedBy
        self.gradedDate = Date()
        self.statusEnum = .graded
    }
    
    // Grade with rubric
    func gradeWithRubric(rubricScoreId: String, score: Int, feedback: String, gradedBy: String) {
        self.rubricScoreId = rubricScoreId
        grade(score: score, feedback: feedback, gradedBy: gradedBy)
    }
    
    // Request feedback
    func requestFeedback() {
        feedbackRequestFlag = true
    }
    
    // Mark as excused
    func markAsExcused(gradedBy: String, reason: String) {
        self.statusEnum = .excused
        self.feedback = reason
        self.gradedBy = gradedBy
        self.gradedDate = Date()
    }
    
    // Return for revision
    func returnForRevision(feedback: String, gradedBy: String) {
        self.statusEnum = .returned
        self.feedback = feedback
        self.gradedBy = gradedBy
        self.gradedDate = Date()
    }
}

// Enumeration of possible submission statuses
enum CoreSubmissionStatus: String, CaseIterable {
    case notSubmitted = "Not Submitted"
    case draft = "Draft"
    case submitted = "Submitted"
    case late = "Late"
    case resubmitted = "Resubmitted"
    case excused = "Excused"
    case graded = "Graded"
    case returned = "Returned for Revision"
    
    var color: Color {
        switch self {
        case .notSubmitted:
            return .red
        case .draft:
            return .gray
        case .submitted:
            return .green
        case .late:
            return .orange
        case .resubmitted:
            return .blue
        case .excused:
            return .purple
        case .graded:
            return .green
        case .returned:
            return .yellow
        }
    }
    
    var icon: String {
        switch self {
        case .notSubmitted:
            return "xmark.circle"
        case .draft:
            return "doc"
        case .submitted:
            return "checkmark.circle"
        case .late:
            return "clock"
        case .resubmitted:
            return "arrow.triangle.2.circlepath"
        case .excused:
            return "hand.raised"
        case .graded:
            return "star.fill"
        case .returned:
            return "arrow.uturn.backward"
        }
    }
}

// For backward compatibility
typealias SubmissionStatus = CoreSubmissionStatus

// Model for tracking submission history
class SubmissionHistory: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var submissionId: String = ""
    @Persisted var timestamp: Date = Date()
    @Persisted var action: String = ""
    @Persisted var statusBefore: String = ""
    @Persisted var statusAfter: String = ""
    @Persisted var userId: String = "" // ID of user who made the change
    
    convenience init(submissionId: String, action: String, statusBefore: CoreSubmissionStatus, statusAfter: CoreSubmissionStatus, userId: String) {
        self.init()
        self.submissionId = submissionId
        self.action = action
        self.statusBefore = statusBefore.rawValue
        self.statusAfter = statusAfter.rawValue
        self.userId = userId
    }
}
