import Foundation
import SwiftUI
import Charts

// Models for grade level-specific analytics
struct GradeLevelAnalytics {
    let gradeLevel: GradeLevel
    let enrollmentCount: Int
    let averageGPA: Double
    let attendanceRate: Double
    let standardsMasteryRate: Double
    let assignmentCompletionRate: Double
    let topPerformingStudents: [Student]
    let needsImprovementStudents: [Student]
    let subjectPerformance: [SubjectPerformance]
    
    // Demographic breakdown
    struct Demographics {
        let categories: [String]
        let counts: [Int]
        let percentages: [Double]
    }
    let demographics: Demographics
    
    // Year-over-year trends
    struct YearlyTrend {
        let years: [String]
        let values: [Double]
    }
    let gpaYearlyTrend: YearlyTrend
    let attendanceYearlyTrend: YearlyTrend
    
    // Subject growth over time
    struct SubjectGrowth {
        let subject: String
        let periods: [String] // e.g., "Q1", "Q2", "Q3", "Q4"
        let averageScores: [Double]
    }
    let subjectGrowths: [SubjectGrowth]
}

// Performance summary by grade level
struct GradeLevelPerformanceSummary: Identifiable {
    let id = UUID()
    let gradeLevel: GradeLevel
    let studentCount: Int
    let averageGPA: Double
    let standardsMastery: Double // percentage
    let attendanceRate: Double // percentage
    let gradeTrend: GradeTrend
    
    enum GradeTrend: String {
        case improving = "Improving"
        case stable = "Stable"
        case declining = "Declining"
        
        var icon: String {
            switch self {
            case .improving: return "arrow.up.right"
            case .stable: return "arrow.right"
            case .declining: return "arrow.down.right"
            }
        }
        
        var color: Color {
            switch self {
            case .improving: return .green
            case .stable: return .blue
            case .declining: return .red
            }
        }
    }
}

// Subject performance by grade level
struct GradeLevelSubjectPerformance: Identifiable {
    let id = UUID()
    let gradeLevel: GradeLevel
    let subject: String
    let averageScore: Double
    let aboveTargetPercentage: Double
    let belowTargetPercentage: Double
    let targetScore: Double
}

// Achievement gap analysis by grade level
struct GradeLevelAchievementGap: Identifiable {
    let id = UUID()
    let gradeLevel: GradeLevel
    let category: String // e.g., "Gender", "Socioeconomic Status", etc.
    let groups: [String] // e.g., ["Male", "Female"] or ["Low Income", "Middle Income", "High Income"]
    let averageScores: [Double] // Average scores corresponding to each group
}

// Grade level transition analysis
struct GradeLevelTransition: Identifiable {
    let id = UUID()
    let fromGradeLevel: GradeLevel
    let toGradeLevel: GradeLevel
    let totalStudents: Int
    let averageGrowth: Double // Change in GPA
    let subjectChanges: [SubjectChange]
    
    struct SubjectChange: Identifiable {
        let id = UUID()
        let subject: String
        let averageScoreChange: Double
        let significantDrop: Bool
        let significantImprovement: Bool
    }
}

// Grade level cohort data for longitudinal analysis
struct GradeLevelCohort: Identifiable {
    let id = UUID()
    let cohortName: String // e.g., "Class of 2025"
    let startYear: Int
    let currentGradeLevel: GradeLevel
    let studentCount: Int
    let retentionRate: Double // percentage of original cohort still enrolled
    let yearlyData: [YearlyPerformance]
    
    struct YearlyPerformance: Identifiable {
        let id = UUID()
        let schoolYear: String // e.g., "2022-2023"
        let gradeLevel: GradeLevel
        let averageGPA: Double
        let attendanceRate: Double
        let standardsMastery: Double
    }
}

// Grade level intervention data
struct GradeLevelIntervention: Identifiable {
    let id = UUID()
    let gradeLevel: GradeLevel
    let interventionName: String
    let targetGroup: String // e.g., "Below 70% in Math"
    let startDate: Date
    let endDate: Date?
    let studentCount: Int
    let averageScoreBefore: Double
    let averageScoreAfter: Double
    let successRate: Double // percentage of students who improved
}

// Models for charting grade level data
extension GradeLevelAnalytics {
    // Convert to chart-friendly format for grade level comparison
    func toGradeLevelComparisonChart() -> [GradeLevelChartData] {
        // Placeholder implementation - would be expanded with real data
        return [
            GradeLevelChartData(metric: "GPA", value: averageGPA, maxValue: 4.0),
            GradeLevelChartData(metric: "Attendance", value: attendanceRate, maxValue: 100.0),
            GradeLevelChartData(metric: "Standards Mastery", value: standardsMasteryRate, maxValue: 100.0),
            GradeLevelChartData(metric: "Assignment Completion", value: assignmentCompletionRate, maxValue: 100.0)
        ]
    }
    
    // Chart data structure for grade level metrics
    struct GradeLevelChartData: Identifiable {
        let id = UUID()
        let metric: String
        let value: Double
        let maxValue: Double
        
        var percentage: Double {
            return (value / maxValue) * 100
        }
    }
    
    // Process data for subject comparison
    func toSubjectComparisonChart() -> [SubjectChartData] {
        return subjectPerformance.map { performance in
            SubjectChartData(
                subject: performance.subject,
                value: performance.averageGrade
            )
        }
    }
    
    // Chart data structure for subject comparison
    struct SubjectChartData: Identifiable {
        let id = UUID()
        let subject: String
        let value: Double
    }
}