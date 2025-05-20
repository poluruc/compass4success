import Foundation
import RealmSwift
import SwiftUI

// Model for defining rubrics to score assignments
public class Rubric: Object, Identifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var name: String = ""
    @Persisted public var rubricdDscription: String = ""
    @Persisted public var totalPoints: Double = 100.0
    @Persisted public var createdBy: String = "" // User ID of creator
    @Persisted public var createdAt: Date = Date()
    @Persisted public var lastModified: Date = Date()
    @Persisted public var isShared: Bool = false // Whether other teachers can use it
    @Persisted public var criteria = List<RubricCriterion>()
    
    public override init() {
        super.init()
    }
    
    // Generate a blank rubric with typical criteria
    static func createDefaultRubric(name: String, totalPoints: Double = 100.0) -> Rubric {
        let rubric = Rubric()
        rubric.name = name
        rubric.totalPoints = totalPoints
        
        // Create default criteria for common learning outcomes
        let pointsPerCriterion = totalPoints / 4.0
        
        let criterionNames = [
            "Understanding of Concepts",
            "Application of Knowledge",
            "Critical Thinking",
            "Communication"
        ]
        
        let rubricdDscriptions = [
            "Demonstrates understanding of key concepts and principles",
            "Applies knowledge to solve problems and analyze situations",
            "Evaluates information, draws conclusions, and shows original thinking",
            "Communicates ideas clearly and effectively"
        ]
        
        for i in 0..<4 {
            let criterion = RubricCriterion()
            criterion.name = criterionNames[i]
            criterion.rubricdDscription = rubricdDscriptions[i]
            criterion.points = pointsPerCriterion
            
            // Add default levels
            for level in 1...4 {
                let rubricLevel = RubricLevel()
                rubricLevel.level = level
                rubricLevel.rubricLevelDescription = getDefaultLevelDescription(for: level)
                rubricLevel.percentage = getLevelPercentage(for: level)
                criterion.levels.append(rubricLevel)
            }
            
            rubric.criteria.append(criterion)
        }
        
        return rubric
    }
    
    // Helper to get default level rubricdDscriptions
    private static func getDefaultLevelDescription(for level: Int) -> String {
        switch level {
        case 1:
            return "Limited achievement of expected learning outcomes"
        case 2:
            return "Some achievement of expected learning outcomes"
        case 3:
            return "Considerable achievement of expected learning outcomes"
        case 4:
            return "Thorough achievement of expected learning outcomes"
        default:
            return "Not assessed"
        }
    }
    
    // Helper to get default percentage for level
    private static func getLevelPercentage(for level: Int) -> Double {
        switch level {
        case 1: return 0.5  // 50%
        case 2: return 0.65 // 65%
        case 3: return 0.8  // 80%
        case 4: return 1.0  // 100%
        default: return 0.0
        }
    }
    
    // Computed property for maximum possible score
    public var maxScore: Int {
        return Int(totalPoints)
    }
}

// Model for a rubric criterion
public class RubricCriterion: Object, Identifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var name: String = ""
    @Persisted public var rubricdDscription: String = ""
    @Persisted public var points: Double = 25.0 // Default to 25 (assuming 4 criteria for 100 points)
    @Persisted public var levels = List<RubricLevel>()
    
    public override init() {
        super.init()
    }
}

// Model for rubric levels (1-4 in Ontario curriculum)
public class RubricLevel: Object, Identifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var level: Int = 0
    @Persisted public var rubricLevelDescription: String = ""
    @Persisted public var percentage: Double = 0.0 // How much of the criterion's points this level is worth
    
    public override init() {
        super.init()
    }
    
    // Calculate points based on percentage of criterion points
    func calculatePoints(forCriterionPoints criterionPoints: Double) -> Double {
        return criterionPoints * percentage
    }
}

// Note: We've removed RubricScore and CriterionScore classes
// as they are defined in RubricScore.swift
