import Foundation
import RealmSwift

class SchoolClass: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var name: String = ""
    @Persisted var clazzCode: String = "" // Renamed from classCode to avoid conflict with NSScriptClassDescription
    @Persisted var courseCode: String = ""  // Added for compatibility
    @Persisted var subject: String = ""
    @Persisted var gradeLevel: String = ""
    @Persisted var period: Int = 0
    @Persisted var roomNumber: String = ""
    @Persisted var teacherId: String = ""
    @Persisted var schoolYear: String = ""
    @Persisted var semester: String = ""
    @Persisted var startDate: Date = Date()
    @Persisted var endDate: Date = Date()
    @Persisted var isActive: Bool = true
    @Persisted var students = List<Student>()
    @Persisted var assignments = List<Assignment>()
    @Persisted var finalGrade: Double? = nil
    
    // Computed property to get number of enrolled students
    var enrollmentCount: Int {
        return students.count
    }
    
    // For compatibility
    var studentCount: Int {
        get { return enrollmentCount }
        set { /* No-op, just for compatibility */ }
    }
    
    // Computed property to get number of active assignments
    var activeAssignmentsCount: Int {
        return assignments.filter { $0.isActive }.count
    }
    
    // Calculate class average grade for all assignments
    var averageGrade: Double? {
        if assignments.isEmpty {
            return nil
        }
        
        var totalPoints = 0.0
        var totalWeight = 0.0
        
        for assignment in assignments {
            if let grade = assignmentAverageGrade(assignment) {
                totalPoints += grade * assignment.weight
                totalWeight += assignment.weight
            }
        }
        
        return totalWeight > 0 ? totalPoints / totalWeight : nil
    }
    
    // Custom initializer for mock data
    convenience init(id: String, name: String, clazzCode: String, courseCode: String, gradeLevel: String) {
        self.init()
        self.id = id
        self.name = name
        self.courseCode = courseCode
        self.clazzCode = clazzCode  // For backward compatibility
        self.gradeLevel = gradeLevel
    }
    
    // Calculate average grade for a specific assignment
    private func assignmentAverageGrade(_ assignment: Assignment) -> Double? {
        if assignment.submissions.isEmpty {
            return nil
        }
        
        var total = 0.0
        var count = 0
        
        for submission in assignment.submissions {
            total += Double(submission.score)
            count += 1
        }
        
        return count > 0 ? (total / Double(count)) * 100.0 / Double(assignment.totalPoints) : nil
    }
    
    // Check if class is currently in session
    var isInSession: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }
    
    // Format the average grade for display
    var formattedAverageGrade: String {
        if let avg = averageGrade {
            return String(format: "%.1f%%", avg * 100)
        } else {
            return "N/A"
        }
    }
}
