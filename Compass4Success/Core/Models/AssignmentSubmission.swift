import Foundation
import RealmSwift

class AssignmentSubmission: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var assignmentId: String = ""
    @Persisted var studentId: String = ""
    @Persisted var submissionDate: Date = Date()
    @Persisted var score: Int? = nil
    @Persisted var feedback: String = ""
    @Persisted var status: String = SubmissionStatus.notSubmitted.rawValue
    @Persisted var attachments = List<String>()
    @Persisted var notes: String = ""
    
    // Added for compatibility with AssignmentsViewModel
    var grade: Double {
        get {
            return Double(score ?? 0)
        }
        set {
            score = Int(newValue)
        }
    }
    
    // Convenience property for formatted score (default version)
    var formattedScore: String {
        guard let scoreValue = score else { return "Not Graded" }
        
        if let assignment = getAssignment() {
            return "\(scoreValue)/\(assignment.totalPoints)"
        } else {
            return "\(scoreValue)/100"
        }
    }
    
    enum SubmissionStatus: String, CaseIterable {
        case notSubmitted = "Not Submitted"
        case submitted = "Submitted"
        case late = "Late"
        case graded = "Graded"
        case excused = "Excused"
        case missing = "Missing"
        
        var color: String {
            switch self {
            case .notSubmitted:
                return "gray"
            case .submitted:
                return "blue"
            case .late:
                return "orange"
            case .graded:
                return "green"
            case .excused:
                return "purple"
            case .missing:
                return "red"
            }
        }
    }
    
    var statusEnum: SubmissionStatus {
        return SubmissionStatus(rawValue: status) ?? .notSubmitted
    }
    
    var scorePercentage: Double? {
        guard let score = score, let assignment = getAssignment() else { return nil }
        return Double(score) / Double(assignment.totalPoints) * 100.0
    }
    
    var letterGrade: String? {
        guard let percentage = scorePercentage else { return nil }
        
        switch percentage {
        case 90...100:
            return "A"
        case 80..<90:
            return "B"
        case 70..<80:
            return "C"
        case 60..<70:
            return "D"
        default:
            return "F"
        }
    }
    
    // Remove the second implementation in favor of the combined one above
    private func getAssignment() -> Assignment? {
        // In a real app, this would fetch the assignment from Realm
        // For now, we'll return nil since we don't have access to Realm
        return nil
    }
}
