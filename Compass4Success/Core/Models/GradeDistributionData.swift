import Foundation
import SwiftUI
import Charts

// Models for grade distribution analysis
struct GradeDistributionData: Identifiable {
    let id = UUID()
    let context: DistributionContext
    let totalStudents: Int
    let distribution: [GradeRange: Int]
    let averageScore: Double
    let medianScore: Double
    let standardDeviation: Double
    let mode: Double?
    let minimumScore: Double
    let maximumScore: Double
    
    // Enumerations for grade distribution categories
    enum GradeRange: String, CaseIterable, Identifiable, Comparable {
        case aPlus = "A+ (97-100%)"
        case a = "A (93-96%)"
        case aMinus = "A- (90-92%)"
        case bPlus = "B+ (87-89%)"
        case b = "B (83-86%)"
        case bMinus = "B- (80-82%)"
        case cPlus = "C+ (77-79%)"
        case c = "C (73-76%)"
        case cMinus = "C- (70-72%)"
        case dPlus = "D+ (67-69%)"
        case d = "D (63-66%)"
        case dMinus = "D- (60-62%)"
        case f = "F (0-59%)"
        
        var id: String { self.rawValue }
        
        static func < (lhs: GradeRange, rhs: GradeRange) -> Bool {
            return lhs.numericValue > rhs.numericValue // Note: Reversed to put A+ first
        }
        
        var numericValue: Double {
            switch self {
            case .aPlus: return 98.5
            case .a: return 94.5
            case .aMinus: return 91
            case .bPlus: return 88
            case .b: return 84.5
            case .bMinus: return 81
            case .cPlus: return 78
            case .c: return 74.5
            case .cMinus: return 71
            case .dPlus: return 68
            case .d: return 64.5
            case .dMinus: return 61
            case .f: return 50
            }
        }
        
        var color: Color {
            switch self {
            case .aPlus, .a, .aMinus:
                return .green
            case .bPlus, .b, .bMinus:
                return .blue
            case .cPlus, .c, .cMinus:
                return .yellow
            case .dPlus, .d, .dMinus:
                return .orange
            case .f:
                return .red
            }
        }
        
        static func forScore(_ score: Double) -> GradeRange {
            switch score {
            case 97...100: return .aPlus
            case 93..<97: return .a
            case 90..<93: return .aMinus
            case 87..<90: return .bPlus
            case 83..<87: return .b
            case 80..<83: return .bMinus
            case 77..<80: return .cPlus
            case 73..<77: return .c
            case 70..<73: return .cMinus
            case 67..<70: return .dPlus
            case 63..<67: return .d
            case 60..<63: return .dMinus
            default: return .f
            }
        }
        
        var letterGrade: String {
            switch self {
            case .aPlus: return "A+"
            case .a: return "A"
            case .aMinus: return "A-"
            case .bPlus: return "B+"
            case .b: return "B"
            case .bMinus: return "B-"
            case .cPlus: return "C+"
            case .c: return "C"
            case .cMinus: return "C-"
            case .dPlus: return "D+"
            case .d: return "D"
            case .dMinus: return "D-"
            case .f: return "F"
            }
        }
        
        // Range for each grade bracket
        var range: ClosedRange<Double> {
            switch self {
            case .aPlus: return 97...100
            case .a: return 93...96.99
            case .aMinus: return 90...92.99
            case .bPlus: return 87...89.99
            case .b: return 83...86.99
            case .bMinus: return 80...82.99
            case .cPlus: return 77...79.99
            case .c: return 73...76.99
            case .cMinus: return 70...72.99
            case .dPlus: return 67...69.99
            case .d: return 63...66.99
            case .dMinus: return 60...62.99
            case .f: return 0...59.99
            }
        }
    }
    
    // Context for what this distribution represents
    enum DistributionContext: Equatable {
        case assignment(id: String, name: String)
        case class(id: String, name: String)
        case subject(name: String)
        case gradeLevel(level: GradeLevel)
        case school
        
        var description: String {
            switch self {
            case .assignment(_, let name):
                return "Assignment: \(name)"
            case .class(_, let name):
                return "Class: \(name)"
            case .subject(let name):
                return "Subject: \(name)"
            case .gradeLevel(let level):
                return "Grade Level: \(level.name)"
            case .school:
                return "School-wide"
            }
        }
    }
    
    // Convert to chart-ready data
    func toChartData() -> [ChartDataPoint] {
        return GradeRange.allCases.compactMap { range in
            let count = distribution[range] ?? 0
            return ChartDataPoint(
                label: range.rawValue,
                value: Double(count),
                color: range.color
            )
        }
    }
    
    // Compute the percentage of students in a certain range
    func percentageInRange(_ ranges: [GradeRange]) -> Double {
        guard totalStudents > 0 else { return 0 }
        
        let count = ranges.reduce(0) { total, range in
            total + (distribution[range] ?? 0)
        }
        
        return (Double(count) / Double(totalStudents)) * 100
    }
    
    // Determine if the distribution shows a healthy pattern
    var isHealthyDistribution: Bool {
        let passingPercentage = percentageInRange(GradeRange.allCases.filter { $0 != .f })
        return passingPercentage >= 80 && standardDeviation < 15
    }
    
    // Simplified version for generating quick insights
    func getDistributionInsights() -> [String] {
        var insights: [String] = []
        
        // Calculate passing rate
        let passingPercentage = percentageInRange(GradeRange.allCases.filter { $0 != .f })
        if passingPercentage >= 90 {
            insights.append("Excellent passing rate of \(Int(passingPercentage))%")
        } else if passingPercentage >= 80 {
            insights.append("Good passing rate of \(Int(passingPercentage))%")
        } else if passingPercentage >= 70 {
            insights.append("Moderate passing rate of \(Int(passingPercentage))%")
        } else {
            insights.append("Concerning passing rate of \(Int(passingPercentage))%")
        }
        
        // Calculate A/B rate
        let abPercentage = percentageInRange([.aPlus, .a, .aMinus, .bPlus, .b, .bMinus])
        if abPercentage >= 60 {
            insights.append("\(Int(abPercentage))% of students earned A or B grades")
        }
        
        // Check for failing students
        let failingPercentage = percentageInRange([.f])
        if failingPercentage >= 20 {
            insights.append("High failure rate: \(Int(failingPercentage))% of students failing")
        }
        
        // Check for distribution shape
        if standardDeviation < 10 {
            insights.append("Tight grade clustering (SD = \(String(format: "%.1f", standardDeviation)))")
        } else if standardDeviation > 20 {
            insights.append("Wide grade dispersion (SD = \(String(format: "%.1f", standardDeviation)))")
        }
        
        return insights
    }
}