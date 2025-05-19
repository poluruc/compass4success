import Foundation
import RealmSwift

// Model to represent different roles in a team teaching scenario
enum TeamTeachingRole: String, CaseIterable, PersistableEnum, Codable {
    case leadTeacher = "Lead Teacher"
    case coTeacher = "Co-Teacher"
    case assistantTeacher = "Assistant Teacher"
    case specialist = "Specialist"
    case guestInstructor = "Guest Instructor"
    case student = "Student Teacher"
    
    var description: String {
        switch self {
        case .leadTeacher:
            return "Primary instructor responsible for curriculum planning and delivery"
        case .coTeacher:
            return "Equal collaborator sharing planning and instruction responsibilities"
        case .assistantTeacher:
            return "Supports the lead teacher with instruction and student assistance"
        case .specialist:
            return "Subject matter expert providing specialized instruction"
        case .guestInstructor:
            return "Temporary instructor for specific lessons or units"
        case .student:
            return "Student teacher completing teaching practicum"
        }
    }
    
    var permissions: [String] {
        switch self {
        case .leadTeacher:
            return ["view", "edit", "grade", "report", "manage"]
        case .coTeacher:
            return ["view", "edit", "grade", "report"]
        case .assistantTeacher:
            return ["view", "grade"]
        case .specialist:
            return ["view", "grade", "report"]
        case .guestInstructor:
            return ["view", "limited-edit"]
        case .student:
            return ["view", "supervised-grade"]
        }
    }
    
    var canGrade: Bool {
        return permissions.contains("grade") || permissions.contains("supervised-grade")
    }
    
    var canEdit: Bool {
        return permissions.contains("edit") || permissions.contains("limited-edit")
    }
    
    var canManage: Bool {
        return permissions.contains("manage")
    }
}

// Class to represent a teacher's role in a specific class
class TeacherRoleAssignment: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var teacherId: String = ""
    @Persisted var classId: String = ""
    @Persisted var role: String = TeamTeachingRole.assistantTeacher.rawValue
    @Persisted var startDate: Date = Date()
    @Persisted var endDate: Date? = nil
    @Persisted var notes: String = ""
    
    var roleEnum: TeamTeachingRole {
        get {
            return TeamTeachingRole(rawValue: role) ?? .assistantTeacher
        }
        set {
            role = newValue.rawValue
        }
    }
    
    var isActive: Bool {
        if let endDate = endDate {
            return endDate > Date()
        }
        return true
    }
    
    convenience init(teacherId: String, classId: String, role: TeamTeachingRole, startDate: Date = Date(), endDate: Date? = nil) {
        self.init()
        self.teacherId = teacherId
        self.classId = classId
        self.roleEnum = role
        self.startDate = startDate
        self.endDate = endDate
    }
}

// Extension to Teacher (expected to exist elsewhere in the codebase)
extension Teacher {
    func roleInClass(_ classId: String) -> TeamTeachingRole? {
        // This would be implemented to look up the teacher's role in a specific class
        // Placeholder implementation
        return nil
    }
    
    func classesWithRole(_ role: TeamTeachingRole) -> [String] {
        // This would return class IDs where this teacher has the specified role
        // Placeholder implementation
        return []
    }
}