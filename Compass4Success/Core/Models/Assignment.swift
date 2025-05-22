import Foundation
import RealmSwift
import SwiftUI

// Assignment model for student assignments
public class Assignment: Object, Identifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted var title: String = ""
    @Persisted var assignmentDescription: String = ""
    @Persisted var dueDate: Date = Date().addingTimeInterval(7 * 24 * 60 * 60) // One week from now
    @Persisted var assignedDate: Date = Date()
    @Persisted var category: String = AssignmentCategory.assignment.rawValue
    @Persisted var totalPoints: Double = 100.0
    @Persisted var weight: Double = 1.0
    @Persisted var isActive: Bool = true
    @Persisted var courseId: String = ""
    @Persisted var classId: String? // Deprecated, use classIds instead
    @Persisted var classIds = List<String>() // New: supports multiple classes
    @Persisted var instructions: String = ""
    @Persisted var points: Double = 0.0  // Added for compatibility
    @Persisted var rubricId: String?     // Reference to a rubric if one is attached
    @Persisted var gradeLevels = List<String>()     // List of applicable grade levels
    @Persisted var resourceUrls = List<String>()

    
    // Store a list of submission IDs instead of embedding objects
    @Persisted public var submissions = RealmSwift.List<Submission>()
    
    // Non-persisted properties
    var isPublished: Bool = false
    var categoryId: String?
    
    // Computed property for category enum
    var categoryEnum: AssignmentCategory {
        get {
            return AssignmentCategory(rawValue: category) ?? .assignment
        }
        set {
            category = newValue.rawValue
        }
    }
    
    public override init() {
        super.init()
    }
    
    public convenience init(id: String, title: String, dueDate: Date, assignmentDescription: String) {
        self.init()
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.assignmentDescription = assignmentDescription
    }
}

// Extension for Assignment that provides utility methods
extension Assignment {
    var isSubmitted: Bool {
        return !submissions.isEmpty
    }
    
    var isOverdue: Bool {
        return dueDate < Date() && !isSubmitted
    }
    
    var isPastDue: Bool {
        return dueDate < Date()
    }
    
    var detailedDescription: String {
        return assignmentDescription
    }
    
    var formattedDueDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dueDate)
    }
    
    var daysUntilDue: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: dueDate)
        return components.day ?? 0
    }
    
    // Added methods for grading and submissions
    
    // Calculate statistics about submissions
    var submissionCount: Int {
        return submissions.count
    }
    
    var gradedCount: Int {
        return submissions.filter { 
            $0.statusEnum == .graded || $0.statusEnum == .excused 
        }.count
    }
    
    var completionRate: Double {
        // Note: In a real app, this would need the total number of students
        return 0.0
    }
    
    var averageScore: Double {
        let scoredSubmissions = submissions.filter { $0.score > 0 }
        guard !scoredSubmissions.isEmpty else { return 0 }
        
        let total = scoredSubmissions.reduce(0) { $0 + Double($1.score) }
        return total / Double(scoredSubmissions.count)
    }
    
    // Get submissions by status
    func getSubmissionsByStatus(_ status: CoreSubmissionStatus) -> [Submission] {
        return Array(submissions.filter { $0.statusEnum == status })
    }
    
    // Get student submission
    func getSubmissionForStudent(studentId: String) -> Submission? {
        return submissions.first { $0.studentId == studentId }
    }
    
    /// Creates a deep copy of the assignment with a new ID
    public func makeCopy() -> Assignment {
        let copy = Assignment()
        copy.id = UUID().uuidString
        copy.title = self.title
        copy.assignmentDescription = self.assignmentDescription
        copy.dueDate = self.dueDate
        copy.assignedDate = self.assignedDate
        copy.category = self.category
        copy.totalPoints = self.totalPoints
        copy.weight = self.weight
        copy.isActive = self.isActive
        copy.courseId = self.courseId
        // copy.classId = self.classId // Deprecated
        // Copy all classIds
        let classIdsList = List<String>()
        for cid in self.classIds { classIdsList.append(cid) }
        copy.classIds = classIdsList
        copy.instructions = self.instructions
        copy.points = self.points
        copy.rubricId = self.rubricId
        // Copy grade levels
        let gradeLevelsList = List<String>()
        for level in self.gradeLevels { gradeLevelsList.append(level) }
        copy.gradeLevels = gradeLevelsList
        // Copy submissions
        let submissionsList = List<Submission>()
        for submission in self.submissions {
            let submissionCopy = Submission()
            submissionCopy.id = UUID().uuidString
            submissionCopy.assignmentId = copy.id
            submissionCopy.studentId = submission.studentId
            submissionCopy.submittedDate = submission.submittedDate
            submissionCopy.status = submission.status
            submissionCopy.comments = submission.comments
            submissionCopy.score = submission.score
            submissionCopy.attempts = submission.attempts
            submissionCopy.rubricScoreId = submission.rubricScoreId
            submissionCopy.feedback = submission.feedback
            submissionCopy.graderNotes = submission.graderNotes
            submissionCopy.gradedDate = submission.gradedDate
            submissionCopy.gradedBy = submission.gradedBy
            // Copy attachment URLs
            let attachmentUrlsList = List<String>()
            for url in submission.attachmentUrls { attachmentUrlsList.append(url) }
            submissionCopy.attachmentUrls = attachmentUrlsList
            submissionsList.append(submissionCopy)
        }
        copy.submissions = submissionsList
        return copy
    }
} 
