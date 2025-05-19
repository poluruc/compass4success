import Foundation
import RealmSwift

// Model for tracking student enrollments in classes
class StudentClassEnrollment: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var studentId: String = ""
    @Persisted var classId: String = ""
    @Persisted var enrollmentDate: Date = Date()
    @Persisted var status: String = "Active"
    @Persisted var grade: Double? = nil
    
    var statusEnum: EnrollmentStatus {
        return EnrollmentStatus(rawValue: status) ?? .active
    }
    
    enum EnrollmentStatus: String {
        case active = "Active"
        case dropped = "Dropped"
        case completed = "Completed"
        case pending = "Pending"
        case waitlisted = "Waitlisted"
    }
}

// Extension for Student to provide enrollments capability
extension Student {
    // Add an enrollments property to the Student class
    var enrollments: List<StudentClassEnrollment> {
        // Create a list property on demand if it doesn't exist
        // In a real implementation, this would be an actual @Persisted property
        let list = List<StudentClassEnrollment>()
        return list
    }
}
