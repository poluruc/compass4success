import Foundation
import RealmSwift
import SwiftUI

// Model for curriculum units
class CurriculumUnit: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var title: String = ""
    @Persisted var detailedDescription: String = ""
    @Persisted var subject: String = ""
    @Persisted var gradeLevel: String = ""
    @Persisted var duration: Int = 0 // Number of weeks
    @Persisted var order: Int = 0 // Sequence within the curriculum
    @Persisted var isActive: Bool = true
    @Persisted var startDate: Date?
    @Persisted var endDate: Date?
    @Persisted var createdBy: String = ""
    @Persisted var createdAt: Date = Date()
    @Persisted var updatedAt: Date = Date()
    @Persisted var learningObjectiveIds = List<String>()
    @Persisted var resourceIds = List<String>()
    @Persisted var tags = List<String>()
    
    // Convenience initializer
    convenience init(title: String, description: String, subject: String, gradeLevel: String, duration: Int = 0, order: Int = 0) {
        self.init()
        self.title = title
        self.detailedDescription = description
        self.subject = subject
        self.gradeLevel = gradeLevel
        self.duration = duration
        self.order = order
    }
    
    // Add a learning objective ID
    func addLearningObjective(_ objectiveId: String) {
        if !learningObjectiveIds.contains(objectiveId) {
            learningObjectiveIds.append(objectiveId)
        }
    }
    
    // Add a resource ID
    func addResource(_ resourceId: String) {
        if !resourceIds.contains(resourceId) {
            resourceIds.append(resourceId)
        }
    }
    
    // Add a tag
    func addTag(_ tag: String) {
        if !tags.contains(tag) {
            tags.append(tag)
        }
    }
}

// Model for curriculum lessons within units
class Lesson: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var unitId: String = ""
    @Persisted var title: String = ""
    @Persisted var detailedDescription: String = ""
    @Persisted var objectives: String = ""
    @Persisted var duration: Int = 0 // In minutes
    @Persisted var order: Int = 0
    @Persisted var isActive: Bool = true
    @Persisted var lessonDate: Date?
    @Persisted var lessonType: String = LessonType.direct.rawValue
    @Persisted var differentiation: String = ""
    @Persisted var assessments: String = ""
    @Persisted var materials: String = ""
    @Persisted var notes: String = ""
    @Persisted var learningObjectiveIds = List<String>()
    @Persisted var resourceIds = List<String>()
    
    var lessonTypeEnum: LessonType {
        get {
            return LessonType(rawValue: lessonType) ?? .direct
        }
        set {
            lessonType = newValue.rawValue
        }
    }
    
    // Convenience initializer
    convenience init(unitId: String, title: String, description: String, duration: Int = 45, order: Int = 0, lessonType: LessonType = .direct) {
        self.init()
        self.unitId = unitId
        self.title = title
        self.detailedDescription = description
        self.duration = duration
        self.order = order
        self.lessonTypeEnum = lessonType
    }
    
    // Add a learning objective ID
    func addLearningObjective(_ objectiveId: String) {
        if !learningObjectiveIds.contains(objectiveId) {
            learningObjectiveIds.append(objectiveId)
        }
    }
}

// Enumeration of lesson types
enum LessonType: String, CaseIterable {
    case direct = "Direct Instruction"
    case inquiry = "Inquiry-Based"
    case project = "Project-Based"
    case collaborative = "Collaborative Learning"
    case independent = "Independent Study"
    case assessment = "Assessment"
    case review = "Review"
    case lab = "Laboratory"
    case discussion = "Discussion"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .direct:
            return "person.fill.viewfinder"
        case .inquiry:
            return "questionmark.circle"
        case .project:
            return "hammer"
        case .collaborative:
            return "person.3"
        case .independent:
            return "person"
        case .assessment:
            return "checkmark.square"
        case .review:
            return "arrow.clockwise"
        case .lab:
            return "flask"
        case .discussion:
            return "bubble.left.and.bubble.right"
        case .other:
            return "ellipsis.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .direct:
            return .blue
        case .inquiry:
            return .purple
        case .project:
            return .green
        case .collaborative:
            return .orange
        case .independent:
            return .yellow
        case .assessment:
            return .red
        case .review:
            return .gray
        case .lab:
            return .mint
        case .discussion:
            return .indigo
        case .other:
            return .secondary
        }
    }
}

// Model for curriculum resources
class CurriculumResource: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var title: String = ""
    @Persisted var detailedDescription: String = ""
    @Persisted var url: String?
    @Persisted var resourceType: String = ResourceType.document.rawValue
    @Persisted var createdBy: String = ""
    @Persisted var createdAt: Date = Date()
    @Persisted var subject: String = ""
    @Persisted var gradeLevel: String = ""
    @Persisted var isPublic: Bool = false
    @Persisted var tags = List<String>()
    
    var resourceTypeEnum: ResourceType {
        get {
            return ResourceType(rawValue: resourceType) ?? .document
        }
        set {
            resourceType = newValue.rawValue
        }
    }
    
    // Convenience initializer
    convenience init(title: String, description: String, url: String? = nil, resourceType: ResourceType = .document) {
        self.init()
        self.title = title
        self.detailedDescription = description
        self.url = url
        self.resourceTypeEnum = resourceType
    }
    
    // Add a tag
    func addTag(_ tag: String) {
        if !tags.contains(tag) {
            tags.append(tag)
        }
    }
}

// Enumeration of resource types
enum ResourceType: String, CaseIterable {
    case document = "Document"
    case video = "Video"
    case audio = "Audio"
    case presentation = "Presentation"
    case worksheet = "Worksheet"
    case quiz = "Quiz"
    case activity = "Activity"
    case link = "Link"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .document:
            return "doc.text"
        case .video:
            return "video"
        case .audio:
            return "speaker.wave.2"
        case .presentation:
            return "chart.bar.doc.horizontal"
        case .worksheet:
            return "list.bullet.clipboard"
        case .quiz:
            return "square.and.pencil"
        case .activity:
            return "figure.walk"
        case .link:
            return "link"
        case .other:
            return "questionmark"
        }
    }
}