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
    @Persisted var classId: String?
    @Persisted var instructions: String = ""
    @Persisted var points: Double = 0.0  // Added for compatibility
    
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
} 
