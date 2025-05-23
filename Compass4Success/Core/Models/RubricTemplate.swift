import Foundation

public struct RubricTemplate: Codable, Identifiable {
    public let id: String
    public let title: String
    public let rubricDescription: String
    public let applicableGrades: [Int]
    public let criteria: [RubricTemplateCriterion]
    
    public init(id: String, title: String, rubricDescription: String, applicableGrades: [Int], criteria: [RubricTemplateCriterion]) {
        self.id = id
        self.title = title
        self.rubricDescription = rubricDescription
        self.applicableGrades = applicableGrades
        self.criteria = criteria
    }
}

public struct RubricTemplateCriterion: Codable, Identifiable {
    public var id: String { name }
    public let name: String
    public let levels: [RubricTemplateLevel]
    
    public init(name: String, levels: [RubricTemplateLevel]) {
        self.name = name
        self.levels = levels
    }
}

public struct RubricTemplateLevel: Codable, Identifiable {
    public var id: Int { level }
    public let level: Int
    public let rubricTemplateLevelDescription: String
    
    public init(level: Int, rubricTemplateLevelDescription: String) {
        self.level = level
        self.rubricTemplateLevelDescription = rubricTemplateLevelDescription
    }
}
