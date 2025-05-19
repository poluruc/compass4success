import Foundation
import SwiftUI

enum AchievementLevel: Int, CaseIterable, Identifiable, Codable {
    case level1 = 1
    case level2 = 2
    case level3 = 3
    case level4 = 4
    
    var id: Int {
        return self.rawValue
    }
    
    var label: String {
        switch self {
        case .level1:
            return "Level 1"
        case .level2:
            return "Level 2"
        case .level3:
            return "Level 3"
        case .level4:
            return "Level 4"
        }
    }
    
    var description: String {
        switch self {
        case .level1:
            return "Below Basic - Student demonstrates minimal understanding and requires significant support."
        case .level2:
            return "Basic - Student demonstrates partial understanding but requires some support."
        case .level3:
            return "Proficient - Student demonstrates adequate understanding with independence."
        case .level4:
            return "Advanced - Student demonstrates thorough understanding and can apply concepts."
        }
    }
    
    var color: Color {
        switch self {
        case .level1:
            return .red
        case .level2:
            return .orange
        case .level3:
            return .blue
        case .level4:
            return .green
        }
    }
    
    static func forScore(_ score: Double, totalPoints: Double) -> AchievementLevel {
        let percentage = (score / totalPoints) * 100
        
        switch percentage {
        case 0..<60:
            return .level1
        case 60..<75:
            return .level2
        case 75..<90:
            return .level3
        default:
            return .level4
        }
    }
}
