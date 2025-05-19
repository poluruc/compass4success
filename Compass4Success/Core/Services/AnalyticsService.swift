import Foundation
import SwiftUI

@available(macOS 13.0, iOS 16.0, *)
class AnalyticsService {
    private let mockService = MockDataService.shared
    
    // Generate mock data for grade distribution chart
    func getGradeDistribution(classId: String?) -> [ChartDataPoint] {
        // Generate mock data
        return [
            ChartDataPoint(label: "A (90-100%)", value: Double.random(in: 3...8)),
            ChartDataPoint(label: "B (80-89%)", value: Double.random(in: 5...10)),
            ChartDataPoint(label: "C (70-79%)", value: Double.random(in: 4...9)),
            ChartDataPoint(label: "D (60-69%)", value: Double.random(in: 2...5)),
            ChartDataPoint(label: "F (0-59%)", value: Double.random(in: 0...3))
        ]
    }
    
    // Generate mock data for assignment completion chart
    func getAssignmentCompletionData(classId: String?) -> [ChartDataPoint] {
        // Generate mock data
        return [
            ChartDataPoint(label: "Completed", value: Double.random(in: 20...35)),
            ChartDataPoint(label: "Late", value: Double.random(in: 5...10)),
            ChartDataPoint(label: "Missing", value: Double.random(in: 0...5))
        ]
    }
    
    // Generate mock data for grades over time chart
    func getGradeOverTimeData(timeFrame: AnalyticsTimeFrame, classId: String?) -> [TimeSeriesDataPoint] {
        // Generate dates for the selected time frame
        let endDate = Date()
        let calendar = Calendar.current
        
        var startDate: Date
        var numberOfPoints: Int
        
        switch timeFrame {
        case .month:
            startDate = calendar.date(byAdding: .day, value: -30, to: endDate)!
            numberOfPoints = 30
        case .semester:
            startDate = calendar.date(byAdding: .day, value: -120, to: endDate)!
            numberOfPoints = 8
        case .year:
            startDate = calendar.date(byAdding: .day, value: -365, to: endDate)!
            numberOfPoints = 12
        case .all:
            startDate = calendar.date(byAdding: .day, value: -730, to: endDate)!
            numberOfPoints = 24
        }
        
        // Create time intervals
        let timeInterval = endDate.timeIntervalSince(startDate) / Double(numberOfPoints)
        var dates: [Date] = []
        
        for i in 0..<numberOfPoints {
            let date = startDate.addingTimeInterval(timeInterval * Double(i))
            dates.append(date)
        }
        
        // Create class average series
        var classAverage: [TimeSeriesDataPoint] = []
        var startingGrade = Double.random(in: 70...85)
        
        for date in dates {
            // Generate a realistic fluctuation in grade
            let fluctuation = Double.random(in: -5...5)
            startingGrade = min(100, max(60, startingGrade + fluctuation))
            classAverage.append(TimeSeriesDataPoint(label: "Class Average", date: date, value: startingGrade))
        }
        
        // Create student series
        var topStudent: [TimeSeriesDataPoint] = []
        var strugglingStudent: [TimeSeriesDataPoint] = []
        
        var topStartingGrade = Double.random(in: 85...95)
        var strugglingStartingGrade = Double.random(in: 60...70)
        
        for date in dates {
            // Generate fluctuations
            let topFluctuation = Double.random(in: -3...5)
            let strugglingFluctuation = Double.random(in: -5...7)
            
            topStartingGrade = min(100, max(80, topStartingGrade + topFluctuation))
            strugglingStartingGrade = min(75, max(50, strugglingStartingGrade + strugglingFluctuation))
            
            topStudent.append(TimeSeriesDataPoint(label: "Top Student", date: date, value: topStartingGrade))
            strugglingStudent.append(TimeSeriesDataPoint(label: "Struggling Student", date: date, value: strugglingStartingGrade))
        }
        
        // Combine all series
        var allSeries: [TimeSeriesDataPoint] = []
        allSeries.append(contentsOf: classAverage)
        allSeries.append(contentsOf: topStudent)
        allSeries.append(contentsOf: strugglingStudent)
        
        return allSeries
    }
    
    // Generate mock data for student performance chart
    func getStudentPerformanceData(classId: String?) -> [ChartDataPoint] {
        let mockData = mockService.generateMockData()
        var studentData: [ChartDataPoint] = []
        
        for student in mockData.students.prefix(10) {
            let grade = Double.random(in: 60...95)
            studentData.append(ChartDataPoint(label: student.fullName, value: grade))
        }
        
        return studentData.sorted { $0.value > $1.value }
    }
    
    // Generate mock data for attendance vs grades chart
    func getAttendanceVsGradesData(classId: String?) -> [ScatterPlotDataPoint] {
        let mockData = mockService.generateMockData()
        var scatterData: [ScatterPlotDataPoint] = []
        
        for student in mockData.students {
            let attendance = Double.random(in: 70...100)
            let grade = min(attendance * Double.random(in: 0.8...1.2), 100)
            
            scatterData.append(ScatterPlotDataPoint(
                label: student.fullName,
                x: attendance,
                y: grade
            ))
        }
        
        return scatterData
    }
    
    // Generate insights based on current analytics view
    func getInsights(for analyticsType: AnalyticsViewType, timeFrame: AnalyticsTimeFrame, classId: String?) -> [AnalyticsInsight] {
        switch analyticsType {
        case .gradeDistribution:
            return [
                AnalyticsInsight(
                    title: "Most students in B range",
                    description: "The majority of students are achieving B grades (80-89%). Consider challenging top performers with enrichment.",
                    icon: "chart.bar",
                    color: .blue
                ),
                AnalyticsInsight(
                    title: "Small group needs intervention",
                    description: "About 15% of students are in the D-F range and may need additional support.",
                    icon: "exclamationmark.triangle",
                    color: .orange
                ),
                AnalyticsInsight(
                    title: "Distribution trend is positive",
                    description: "Grade distribution has improved compared to last semester.",
                    icon: "arrow.up.right",
                    color: .green
                )
            ]
            
        case .assignmentCompletion:
            return [
                AnalyticsInsight(
                    title: "High completion rate",
                    description: "Over 85% of assignments are being completed on time. This is above the school average.",
                    icon: "checkmark.circle",
                    color: .green
                ),
                AnalyticsInsight(
                    title: "Late submissions increasing",
                    description: "There's been a 12% increase in late submissions compared to last month.",
                    icon: "clock",
                    color: .orange
                ),
                AnalyticsInsight(
                    title: "Missing assignments concentrated",
                    description: "3 students account for 80% of missing assignments. Consider targeted interventions.",
                    icon: "person.crop.circle.badge.exclamationmark",
                    color: .red
                )
            ]
            
        case .gradeOverTime:
            return [
                AnalyticsInsight(
                    title: "Positive trend overall",
                    description: "Class average has increased 4.5% over the selected time period.",
                    icon: "arrow.up.right",
                    color: .green
                ),
                AnalyticsInsight(
                    title: "Midterm impact visible",
                    description: "Notable dip in grades during midterm week followed by recovery.",
                    icon: "calendar.badge.clock",
                    color: .blue
                ),
                AnalyticsInsight(
                    title: "Top performers consistent",
                    description: "Top 20% of students maintain consistent performance with less fluctuation.",
                    icon: "star",
                    color: .yellow
                )
            ]
            
        case .studentPerformance:
            return [
                AnalyticsInsight(
                    title: "Wide performance gap",
                    description: "There's a 32% difference between highest and lowest performing students.",
                    icon: "arrow.up.and.down",
                    color: .purple
                ),
                AnalyticsInsight(
                    title: "Median grade is B-",
                    description: "The median student grade is 82%, which is slightly above target.",
                    icon: "equal",
                    color: .blue
                ),
                AnalyticsInsight(
                    title: "Targeted intervention needed",
                    description: "3 students are performing significantly below the class median.",
                    icon: "person.fill.questionmark",
                    color: .orange
                )
            ]
            
        case .attendanceVsGrades:
            return [
                AnalyticsInsight(
                    title: "Strong correlation detected",
                    description: "Students with >90% attendance average 15% higher grades.",
                    icon: "link",
                    color: .blue
                ),
                AnalyticsInsight(
                    title: "Attendance threshold identified",
                    description: "Students dropping below 80% attendance show significant grade impacts.",
                    icon: "chart.line.downtrend.xyaxis",
                    color: .red
                ),
                AnalyticsInsight(
                    title: "Outliers present",
                    description: "2 students with low attendance maintain high grades, suggesting alternative learning styles.",
                    icon: "person.fill.viewfinder",
                    color: .purple
                )
            ]
        }
    }
    
    // Generate data for grade level analytics
    func getGradeLevelPerformance() -> [GradeLevelPerformance] {
        return [
            GradeLevelPerformance(
                gradeLevel: "9",
                averageGrade: Double.random(in: 75...85),
                targetGrade: 80
            ),
            GradeLevelPerformance(
                gradeLevel: "10", 
                averageGrade: Double.random(in: 73...83),
                targetGrade: 80
            ),
            GradeLevelPerformance(
                gradeLevel: "11",
                averageGrade: Double.random(in: 77...87), 
                targetGrade: 80
            ),
            GradeLevelPerformance(
                gradeLevel: "12",
                averageGrade: Double.random(in: 80...90),
                targetGrade: 80
            )
        ]
    }
    
    // Generate data for subject performance analytics
    func getSubjectPerformance() -> [SubjectPerformance] {
        return [
            SubjectPerformance(
                subject: "Mathematics",
                averageGrade: Double.random(in: 75...85),
                studentCount: Int.random(in: 80...120)
            ),
            SubjectPerformance(
                subject: "Science",
                averageGrade: Double.random(in: 78...88),
                studentCount: Int.random(in: 80...120)
            ),
            SubjectPerformance(
                subject: "English",
                averageGrade: Double.random(in: 80...90),
                studentCount: Int.random(in: 80...120)
            ),
            SubjectPerformance(
                subject: "History",
                averageGrade: Double.random(in: 82...92),
                studentCount: Int.random(in: 80...120)
            ),
            SubjectPerformance(
                subject: "Art",
                averageGrade: Double.random(in: 85...95),
                studentCount: Int.random(in: 40...80)
            ),
            SubjectPerformance(
                subject: "Physical Education",
                averageGrade: Double.random(in: 88...98),
                studentCount: Int.random(in: 80...120)
            )
        ]
    }
}