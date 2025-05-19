import Foundation
import RealmSwift

// Model for storing grade data for student assignments
class Grade: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var studentId: String = ""
    @Persisted var assignmentId: String = ""
    @Persisted var classId: String = ""
    @Persisted var score: Double = 0.0
    @Persisted var maxScore: Double = 100.0
    @Persisted var submittedDate: Date?
    @Persisted var gradedDate: Date?
    @Persisted var gradedBy: String = "" // User ID of the teacher who graded it
    @Persisted var comments: String = ""
    @Persisted var isExempt: Bool = false
    @Persisted var isIncomplete: Bool = false
    @Persisted var isMissing: Bool = false
    @Persisted var rubricScoreId: String? // Optional reference to detailed rubric scoring
    @Persisted var overrideReason: String = "" // If grade was manually overridden
    
    // Computed property for percentage score
    var percentage: Double {
        guard maxScore > 0 else { return 0 }
        return (score / maxScore) * 100
    }
    
    // Computed property for letter grade
    var letterGrade: String {
        switch percentage {
        case 97...100:
            return "A+"
        case 93..<97:
            return "A"
        case 90..<93:
            return "A-"
        case 87..<90:
            return "B+"
        case 83..<87:
            return "B"
        case 80..<83:
            return "B-"
        case 77..<80:
            return "C+"
        case 73..<77:
            return "C"
        case 70..<73:
            return "C-"
        case 67..<70:
            return "D+"
        case 63..<67:
            return "D"
        case 60..<63:
            return "D-"
        default:
            return "F"
        }
    }
    
    // Computed property for achievement level
    var achievementLevel: AchievementLevel {
        return AchievementLevel.forScore(score, totalPoints: maxScore)
    }
    
    // Status properties
    var status: GradeStatus {
        if isExempt {
            return .exempt
        } else if isIncomplete {
            return .incomplete
        } else if isMissing {
            return .missing
        } else if gradedDate != nil {
            return .graded
        } else if submittedDate != nil {
            return .submitted
        } else {
            return .notSubmitted
        }
    }
    
    var daysSinceSubmitted: Int? {
        guard let submittedDate = submittedDate else { return nil }
        return Calendar.current.dateComponents([.day], from: submittedDate, to: Date()).day
    }
    
    var turnaroundTime: Int? {
        guard let submittedDate = submittedDate, let gradedDate = gradedDate else { return nil }
        return Calendar.current.dateComponents([.day], from: submittedDate, to: gradedDate).day
    }
    
    // Convenience initializer
    convenience init(studentId: String, assignmentId: String, classId: String, score: Double, maxScore: Double = 100) {
        self.init()
        self.studentId = studentId
        self.assignmentId = assignmentId
        self.classId = classId
        self.score = score
        self.maxScore = maxScore
    }
    
    // Method to mark as graded
    func markAsGraded(by teacherId: String) {
        gradedBy = teacherId
        gradedDate = Date()
    }
    
    // Method to override the grade
    func override(newScore: Double, reason: String, by teacherId: String) {
        score = newScore
        overrideReason = reason
        gradedBy = teacherId
        gradedDate = Date()
    }
}

// Enumeration of grade statuses
enum GradeStatus: String, CaseIterable {
    case notSubmitted = "Not Submitted"
    case submitted = "Submitted"
    case graded = "Graded"
    case missing = "Missing"
    case incomplete = "Incomplete"
    case exempt = "Exempt"
    
    var color: String {
        switch self {
        case .notSubmitted:
            return "gray"
        case .submitted:
            return "blue"
        case .graded:
            return "green"
        case .missing:
            return "red"
        case .incomplete:
            return "orange"
        case .exempt:
            return "purple"
        }
    }
    
    var icon: String {
        switch self {
        case .notSubmitted:
            return "square"
        case .submitted:
            return "square.and.pencil"
        case .graded:
            return "checkmark.square"
        case .missing:
            return "xmark.square"
        case .incomplete:
            return "ellipsis.circle"
        case .exempt:
            return "minus.circle"
        }
    }
}

// Model for grade trends over time
class GradeTrend: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var studentId: String = ""
    @Persisted var classId: String = ""
    @Persisted var timestamp: Date = Date()
    @Persisted var currentGrade: Double = 0.0
    @Persisted var weightedAverage: Double = 0.0
    @Persisted var previousGrade: Double?
    @Persisted var targetGrade: Double?
    
    // Computed property for change in grade
    var change: Double? {
        guard let previousGrade = previousGrade else { return nil }
        return currentGrade - previousGrade
    }
    
    // Computed property for whether the student is on track to meet their target
    var isOnTrack: Bool {
        guard let targetGrade = targetGrade else { return false }
        return currentGrade >= targetGrade
    }
    
    // Convenience initializer
    convenience init(studentId: String, classId: String, currentGrade: Double, previousGrade: Double? = nil, targetGrade: Double? = nil) {
        self.init()
        self.studentId = studentId
        self.classId = classId
        self.currentGrade = currentGrade
        self.weightedAverage = currentGrade
        self.previousGrade = previousGrade
        self.targetGrade = targetGrade
    }
}