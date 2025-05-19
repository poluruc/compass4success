import Foundation
import RealmSwift
import SwiftUI

// Model for curriculum expectations and standards
class CurriculumExpectation: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var code: String = ""
    @Persisted var title: String = ""
    @Persisted var detailedDescription: String = ""
    @Persisted var subject: String = ""
    @Persisted var gradeLevel: String = ""
    @Persisted var domain: String = ""
    @Persisted var standardSet: String = ""
    @Persisted var isActive: Bool = true
    @Persisted var parentExpectationId: String?
    @Persisted var childExpectationIds = List<String>()
    @Persisted var tags = List<String>()
    @Persisted var priority: Int = 2 // 1 = high, 2 = medium, 3 = low
    
    // Computed property for full standard code
    var fullCode: String {
        var components: [String] = []
        
        if !subject.isEmpty {
            components.append(subject.prefix(3).uppercased())
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
    
    // Computed property for priority level as an enum
    var priorityLevel: PriorityLevel {
        get {
            return PriorityLevel(rawValue: priority) ?? .medium
        }
        set {
            priority = newValue.rawValue
        }
    }
    
    // Convenience initializer
    convenience init(code: String, title: String, description: String, subject: String, gradeLevel: String, domain: String = "", standardSet: String = "", priority: PriorityLevel = .medium) {
        self.init()
        self.code = code
        self.title = title
        self.detailedDescription = description
        self.subject = subject
        self.gradeLevel = gradeLevel
        self.domain = domain
        self.standardSet = standardSet
        self.priorityLevel = priority
    }
    
    // Add a child expectation ID
    func addChildExpectation(_ expectationId: String) {
        if !childExpectationIds.contains(expectationId) {
            childExpectationIds.append(expectationId)
        }
    }
    
    // Add a tag
    func addTag(_ tag: String) {
        if !tags.contains(tag) {
            tags.append(tag)
        }
    }
}

// Priority level enumeration
enum PriorityLevel: Int, CaseIterable {
    case high = 1
    case medium = 2
    case low = 3
    
    var description: String {
        switch self {
        case .high:
            return "High Priority"
        case .medium:
            return "Medium Priority"
        case .low:
            return "Low Priority"
        }
    }
    
    var color: Color {
        switch self {
        case .high:
            return .red
        case .medium:
            return .blue
        case .low:
            return .green
        }
    }
    
    var icon: String {
        switch self {
        case .high:
            return "exclamationmark.triangle"
        case .medium:
            return "star.fill"
        case .low:
            return "checkmark.circle"
        }
    }
}

// Model for tracking a student's progress on curriculum expectations
class ExpectationProgress: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var expectationId: String = ""
    @Persisted var studentId: String = ""
    @Persisted var classId: String = ""
    @Persisted var lastUpdated: Date = Date()
    @Persisted var mastery: Int = 0 // 0-4 scale
    @Persisted var assessmentIds = List<String>()
    @Persisted var notes: String = ""
    
    var masteryLevel: MasteryLevel {
        get {
            return MasteryLevel(rawValue: mastery) ?? .notAssessed
        }
        set {
            mastery = newValue.rawValue
        }
    }
    
    // Convenience initializer
    convenience init(expectationId: String, studentId: String, classId: String, masteryLevel: MasteryLevel = .notAssessed) {
        self.init()
        self.expectationId = expectationId
        self.studentId = studentId
        self.classId = classId
        self.masteryLevel = masteryLevel
    }
    
    // Add an assessment ID
    func addAssessment(_ assessmentId: String) {
        if !assessmentIds.contains(assessmentId) {
            assessmentIds.append(assessmentId)
        }
    }
}

// Model for curriculum mapping (linking expectations to units/lessons)
class CurriculumMap: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var expectationId: String = ""
    @Persisted var unitId: String?
    @Persisted var lessonId: String?
    @Persisted var assignmentId: String?
    @Persisted var weight: Double = 1.0 // How strongly this lesson/assignment addresses the expectation
    @Persisted var notes: String = ""
    
    // Convenience initializer for mapping to a unit
    convenience init(expectationId: String, unitId: String, weight: Double = 1.0) {
        self.init()
        self.expectationId = expectationId
        self.unitId = unitId
        self.weight = weight
    }
    
    // Convenience initializer for mapping to a lesson
    convenience init(expectationId: String, lessonId: String, weight: Double = 1.0) {
        self.init()
        self.expectationId = expectationId
        self.lessonId = lessonId
        self.weight = weight
    }
    
    // Convenience initializer for mapping to an assignment
    convenience init(expectationId: String, assignmentId: String, weight: Double = 1.0) {
        self.init()
        self.expectationId = expectationId
        self.assignmentId = assignmentId
        self.weight = weight
    }
}