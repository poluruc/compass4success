import Foundation

class InMemoryRubricScoreStore {
    static var shared = InMemoryRubricScoreStore()
    // Key: "studentId_assignmentId", Value: [criterionName: selectedLevel]
    private(set) var scores: [String: [String: Int]] = [:]
    
    // Store assignment total points for each assignment
    private var assignmentPoints: [String: Double] = [:]

    func getSelections(studentId: String, assignmentId: String) -> [String: Int] {
        let key = "\(studentId)_\(assignmentId)"
        return scores[key] ?? [:]
    }

    func saveSelections(studentId: String, assignmentId: String, selections: [String: Int], totalPoints: Double) {
        let key = "\(studentId)_\(assignmentId)"
        scores[key] = selections
        assignmentPoints[assignmentId] = totalPoints
    }

    func totalScore(for rubric: RubricTemplate, studentId: String, assignmentId: String, selections: [String: Int]? = nil) -> Int {
        let selectionsToUse = selections ?? getSelections(studentId: studentId, assignmentId: assignmentId)
        return calculateTotalScore(rubric: rubric, selections: selectionsToUse, assignmentId: assignmentId)
    }

    func maxScore(for assignmentId: String) -> Int {
        return Int(assignmentPoints[assignmentId] ?? 100.0)
    }
    
    // Helper function to calculate total score
    private func calculateTotalScore(rubric: RubricTemplate, selections: [String: Int], assignmentId: String) -> Int {
        let totalPoints = assignmentPoints[assignmentId] ?? 100.0
        let pointsPerCriterion = totalPoints / Double(max(1, rubric.criteria.count))
        var total = 0
        
        for criterion in rubric.criteria {
            if let selectedLevel = selections[criterion.name],
               let level = criterion.levels.first(where: { $0.level == selectedLevel }) {
                let percent: Double =
                    selectedLevel == 1 ? 0.5 :
                    selectedLevel == 2 ? 0.65 :
                    selectedLevel == 3 ? 0.8 :
                    selectedLevel == 4 ? 1.0 : 0.0
                total += Int(Double(pointsPerCriterion) * percent)
            }
        }
        return total
    }
} 