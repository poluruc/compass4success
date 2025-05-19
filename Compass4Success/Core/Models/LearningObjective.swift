import Foundation
import RealmSwift

// Model representing a learning objective or standard
class LearningObjective: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var code: String = ""
    @Persisted var title: String = ""
    @Persisted var description: String = ""
    @Persisted var subject: String = ""
    @Persisted var gradeLevel: String = ""
    @Persisted var domain: String = ""
    @Persisted var cluster: String = ""
    @Persisted var standard: String = ""
    @Persisted var isActive: Bool = true
    @Persisted var parentObjectiveId: String?
    @Persisted var childObjectiveIds = List<String>()
    @Persisted var tags = List<String>()
    
    // Computed property for full code (e.g., "MATH.5.NBT.1")
    var fullCode: String {
        var components: [String] = []
        
        if !subject.isEmpty {
            components.append(subject)
        }
        
        if !gradeLevel.isEmpty {
            components.append(gradeLevel)
        }
        
        if !domain.isEmpty {
            components.append(domain)
        }
        
        if !code.isEmpty {
            components.append(code)
        }
        
        return components.joined(separator: ".")
    }
    
    // Convenience initializer for creating learning objectives
    convenience init(code: String, title: String, description: String, subject: String, gradeLevel: String, domain: String = "", cluster: String = "", standard: String = "") {
        self.init()
        self.code = code
        self.title = title
        self.description = description
        self.subject = subject
        self.gradeLevel = gradeLevel
        self.domain = domain
        self.cluster = cluster
        self.standard = standard
    }
    
    // Add a child objective ID
    func addChildObjective(_ objectiveId: String) {
        childObjectiveIds.append(objectiveId)
    }
    
    // Add a tag
    func addTag(_ tag: String) {
        if !tags.contains(tag) {
            tags.append(tag)
        }
    }
}

// Model representing a student's mastery of a learning objective
class ObjectiveMastery: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var objectiveId: String = ""
    @Persisted var studentId: String = ""
    @Persisted var classId: String = ""
    @Persisted var lastUpdated: Date = Date()
    @Persisted var level: Int = 0
    @Persisted var assessmentIds = List<String>()
    @Persisted var notes: String = ""
    
    var masteryLevel: MasteryLevel {
        get {
            return MasteryLevel(rawValue: level) ?? .notAssessed
        }
        set {
            level = newValue.rawValue
        }
    }
    
    // Convenience initializer
    convenience init(objectiveId: String, studentId: String, classId: String, masteryLevel: MasteryLevel = .notAssessed) {
        self.init()
        self.objectiveId = objectiveId
        self.studentId = studentId
        self.classId = classId
        self.masteryLevel = masteryLevel
    }
    
    // Add an assessment ID that contributes to this mastery level
    func addAssessment(_ assessmentId: String) {
        if !assessmentIds.contains(assessmentId) {
            assessmentIds.append(assessmentId)
        }
    }
}

// Enumeration of mastery levels
enum MasteryLevel: Int, CaseIterable {
    case notAssessed = 0
    case beginning = 1
    case developing = 2
    case proficient = 3
    case advanced = 4
    
    var description: String {
        switch self {
        case .notAssessed:
            return "Not Assessed"
        case .beginning:
            return "Beginning"
        case .developing:
            return "Developing"
        case .proficient:
            return "Proficient"
        case .advanced:
            return "Advanced"
        }
    }
    
    var color: String {
        switch self {
        case .notAssessed:
            return "gray"
        case .beginning:
            return "red"
        case .developing:
            return "orange"
        case .proficient:
            return "blue"
        case .advanced:
            return "green"
        }
    }
}

// Model for tracking the alignment between learning objectives and assignments
class ObjectiveAssignment: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var objectiveId: String = ""
    @Persisted var assignmentId: String = ""
    @Persisted var weight: Double = 1.0 // How heavily this assignment affects mastery of the objective
    
    convenience init(objectiveId: String, assignmentId: String, weight: Double = 1.0) {
        self.init()
        self.objectiveId = objectiveId
        self.assignmentId = assignmentId
        self.weight = weight
    }
}