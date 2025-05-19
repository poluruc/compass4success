import Foundation
import RealmSwift

// Rubric model for standardized assessment criteria
class Rubric: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var title: String = ""
    @Persisted var rubricDescription: String = "" // Renamed to avoid conflict with Object.description
    @Persisted var createdAt: Date = Date()
    @Persisted var updatedAt: Date = Date()
    @Persisted var createdBy: String = ""
    @Persisted var isTemplate: Bool = false
    @Persisted var associatedAssignmentId: String = ""
    @Persisted var criteria = List<RubricCriterion>()
    
    // Convenience initializer
    convenience init(title: String, description: String, criteria: [RubricCriterion] = []) {
        self.init()
        self.title = title
        self.rubricDescription = description
        
        let criteriaList = List<RubricCriterion>()
        criteria.forEach { criteriaList.append($0) }
        self.criteria = criteriaList
    }
    
    var maxScore: Int {
        var total = 0
        for criterion in criteria {
            total += criterion.maxScore
        }
        return total
    }
}

// Individual criterion within a rubric
class RubricCriterion: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var title: String = ""
    @Persisted var criterionDescription: String = "" // Renamed to avoid conflict with Object.description
    @Persisted var weight: Double = 1.0
    @Persisted var maxScore: Int = 4
    @Persisted var levels = List<RubricLevel>()
    
    // Convenience initializer
    convenience init(title: String, description: String, maxScore: Int = 4, levels: [RubricLevel] = []) {
        self.init()
        self.title = title
        self.criterionDescription = description
        self.maxScore = maxScore
        
        let levelsList = List<RubricLevel>()
        levels.forEach { levelsList.append($0) }
        self.levels = levelsList
    }
}

// Performance level definition within a criterion
class RubricLevel: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var score: Int = 0
    @Persisted var levelDescription: String = "" // Renamed to avoid conflict with Object.description
    @Persisted var achievementLevel: Int = 0
    
    // Convenience initializer
    convenience init(score: Int, description: String, achievementLevel: AchievementLevel) {
        self.init()
        self.score = score
        self.levelDescription = description
        self.achievementLevel = achievementLevel.rawValue
    }
    
    var achievementLevelEnum: AchievementLevel {
        return AchievementLevel(rawValue: achievementLevel) ?? .level1
    }
}
