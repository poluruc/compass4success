import Foundation
import RealmSwift


// Assignment model for student assignments
class Assignment: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var title: String = ""
    @Persisted var assignmentDescription: String = ""
    @Persisted var dueDate: Date = Date()
    @Persisted var assignedDate: Date = Date()
    @Persisted var category: String = AssignmentCategory.assignment.rawValue
    @Persisted var totalPoints: Int = 100
    @Persisted var weight: Double = 1.0
    @Persisted var isActive: Bool = true
    @Persisted var courseId: String = ""
    @Persisted var classId: String = ""
    @Persisted var instructions: String = ""
    @Persisted var submissions = List<AssignmentSubmission>()
    
    // Convenience initializer for creating assignments
    convenience init(id: String, title: String, dueDate: Date, description: String, submissions: [AssignmentSubmission] = []) {
        self.init()
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.assignmentDescription = description
        
        let submissionsList = List<AssignmentSubmission>()
        submissions.forEach { submissionsList.append($0) }
        self.submissions = submissionsList
    }
}

// Extension for Assignment that provides utility methods
extension Assignment {
    var isSubmitted: Bool {
        return submissions.count > 0
    }
    
    var isOverdue: Bool {
        return dueDate < Date() && !isSubmitted
    }
    
    var isPastDue: Bool {
        return dueDate < Date()
    }
    
    var daysUntilDue: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: dueDate)
        return components.day ?? 0
    }
    
    var formattedDueDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: dueDate)
    }
    
    var categoryEnum: AssignmentCategory {
        return AssignmentCategory(rawValue: category) ?? .assignment
    }
}