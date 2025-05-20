import Foundation

struct RubricTemplate: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let applicableGrades: [Int]
    let criteria: [RubricTemplateCriterion]
}

struct RubricTemplateCriterion: Codable, Identifiable {
    var id: String { name }
    let name: String
    let levels: [RubricTemplateLevel]
}

struct RubricTemplateLevel: Codable {
    let level: Int
    let description: String
} 