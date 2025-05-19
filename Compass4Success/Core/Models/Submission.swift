import Foundation
import RealmSwift
import SwiftUI

// Model representing a student's submission for an assignment
class Submission: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var assignmentId: String = ""
    @Persisted var studentId: String = ""
    @Persisted var submittedDate: Date?
    @Persisted var status: String = SubmissionStatus.notSubmitted.rawValue
    @Persisted var attachmentUrls = List<String>()
    @Persisted var comments: String = ""
    @Persisted var feedbackRequestFlag: Bool = false
    @Persisted var draft: Bool = false
    @Persisted var attempts: Int = 0
    @Persisted var rubricScoreId: String?
    
    // Computed property for the status as an enum
    var statusEnum: SubmissionStatus {
        get {
            return SubmissionStatus(rawValue: status) ?? .notSubmitted
        }
        set {
            status = newValue.rawValue
        }
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
    
    // Reference to associated grade (if any)
    var grade: Grade? {
        // Would be implemented to fetch the grade from the database
        return nil
    }
    
    // Convenience initializer
    convenience init(assignmentId: String, studentId: String, submittedDate: Date? = nil, status: SubmissionStatus = .notSubmitted) {
        self.init()
        self.assignmentId = assignmentId
        self.studentId = studentId
        self.submittedDate = submittedDate
        self.statusEnum = status
    }
    
    // Helper method to get the assignment (placeholder implementation)
    private func getAssignment() -> Assignment? {
        // Would be implemented to fetch the assignment from the database
        // Placeholder implementation
        return nil
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
    
    // Request feedback
    func requestFeedback() {
        feedbackRequestFlag = true
    }
}

// Enumeration of possible submission statuses
enum SubmissionStatus: String, CaseIterable {
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

// Model for tracking submission history
class SubmissionHistory: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var submissionId: String = ""
    @Persisted var timestamp: Date = Date()
    @Persisted var action: String = ""
    @Persisted var statusBefore: String = ""
    @Persisted var statusAfter: String = ""
    @Persisted var userId: String = "" // ID of user who made the change
    
    convenience init(submissionId: String, action: String, statusBefore: SubmissionStatus, statusAfter: SubmissionStatus, userId: String) {
        self.init()
        self.submissionId = submissionId
        self.action = action
        self.statusBefore = statusBefore.rawValue
        self.statusAfter = statusAfter.rawValue
        self.userId = userId
    }
}