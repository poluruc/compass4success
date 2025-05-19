import Foundation
import RealmSwift

// RubricScore model to store student scores for each rubric criterion
class RubricScore: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var submissionId: String = ""
    @Persisted var rubricId: String = ""
    @Persisted var studentId: String = ""
    @Persisted var assignmentId: String = ""
    @Persisted var evaluatorId: String = ""
    @Persisted var scoredAt: Date = Date()
    @Persisted var criterionScores = List<CriterionScore>()
    @Persisted var comments: String = ""
    
    // Convenience initializer
    convenience init(submissionId: String, rubricId: String, studentId: String, assignmentId: String, scores: [CriterionScore] = []) {
        self.init()
        self.submissionId = submissionId
        self.rubricId = rubricId
        self.studentId = studentId
        self.assignmentId = assignmentId
        
        let scoresList = List<CriterionScore>()
        scores.forEach { scoresList.append($0) }
        self.criterionScores = scoresList
    }
    
    // Calculate total score
    var totalScore: Int {
        var total = 0
        for score in criterionScores {
            total += score.score
        }
        return total
    }
    
    // Calculate percentage score based on rubric max possible score
    func percentageScore(rubric: Rubric) -> Double {
        let maxPossible = rubric.maxScore
        return maxPossible > 0 ? Double(totalScore) / Double(maxPossible) * 100 : 0
    }
    
    // Determine overall achievement level
    func overallAchievementLevel(rubric: Rubric) -> AchievementLevel {
        let percentage = percentageScore(rubric: rubric)
        return AchievementLevel.forScore(Double(totalScore), totalPoints: Double(rubric.maxScore))
    }
}

// Individual score for a specific criterion
class CriterionScore: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var criterionId: String = ""
    @Persisted var score: Int = 0
    @Persisted var comment: String = ""
    
    // Convenience initializer
    convenience init(criterionId: String, score: Int, comment: String = "") {
        self.init()
        self.criterionId = criterionId
        self.score = score
        self.comment = comment
    }
}
