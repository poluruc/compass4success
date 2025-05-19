import SwiftUI
import Charts

// Preview provider for analytics components
struct AnalyticsPreviewProvider {
    
    // Generate mock data for grade distribution chart
    static func getGradeDistribution() -> [ChartDataPoint] {
        return [
            ChartDataPoint(label: "A (90-100%)", value: 12),
            ChartDataPoint(label: "B (80-89%)", value: 18),
            ChartDataPoint(label: "C (70-79%)", value: 15),
            ChartDataPoint(label: "D (60-69%)", value: 7),
            ChartDataPoint(label: "F (0-59%)", value: 3)
        ]
    }
    
    // Generate mock data for assignment completion chart
    static func getAssignmentCompletionData() -> [ChartDataPoint] {
        return [
            ChartDataPoint(label: "Completed", value: 42),
            ChartDataPoint(label: "Late", value: 8),
            ChartDataPoint(label: "Missing", value: 5)
        ]
    }
    
    // Generate mock data for grades over time chart
    static func getGradeOverTimeData() -> [TimeSeriesDataPoint] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .month, value: -3, to: endDate)!
        let timeInterval = endDate.timeIntervalSince(startDate) / 10
        var dates: [Date] = []
        
        for i in 0..<10 {
            let date = startDate.addingTimeInterval(timeInterval * Double(i))
            dates.append(date)
        }
        
        // Generate data for Class Average
        var classAvg: [TimeSeriesDataPoint] = []
        var avg = 75.0
        for date in dates {
            avg += Double.random(in: -3...3)
            avg = min(max(avg, 60), 95)
            classAvg.append(TimeSeriesDataPoint(label: "Class Average", date: date, value: avg))
        }
        
        // Generate data for Top Students
        var topAvg: [TimeSeriesDataPoint] = []
        var top = 90.0
        for date in dates {
            top += Double.random(in: -2...2)
            top = min(max(top, 85), 100)
            topAvg.append(TimeSeriesDataPoint(label: "Top Students", date: date, value: top))
        }
        
        // Generate data for Struggling Students
        var lowAvg: [TimeSeriesDataPoint] = []
        var low = 65.0
        for date in dates {
            low += Double.random(in: -4...4)
            low = min(max(low, 50), 75)
            lowAvg.append(TimeSeriesDataPoint(label: "Struggling Students", date: date, value: low))
        }
        
        var result: [TimeSeriesDataPoint] = []
        result.append(contentsOf: classAvg)
        result.append(contentsOf: topAvg)
        result.append(contentsOf: lowAvg)
        
        return result
    }
    
    // Generate mock data for subject performance
    static func getSubjectPerformanceData() -> [SubjectPerformance] {
        return [
            SubjectPerformance(subject: "Math", averageGrade: 82, studentCount: 120),
            SubjectPerformance(subject: "Science", averageGrade: 78, studentCount: 110),
            SubjectPerformance(subject: "English", averageGrade: 85, studentCount: 115),
            SubjectPerformance(subject: "History", averageGrade: 79, studentCount: 105),
            SubjectPerformance(subject: "Art", averageGrade: 92, studentCount: 65)
        ]
    }
    
    // Generate mock data for grade level performance
    static func getGradeLevelPerformanceData() -> [GradeLevelPerformance] {
        return [
            GradeLevelPerformance(gradeLevel: "9", averageGrade: 78, targetGrade: 80),
            GradeLevelPerformance(gradeLevel: "10", averageGrade: 81, targetGrade: 80),
            GradeLevelPerformance(gradeLevel: "11", averageGrade: 84, targetGrade: 80),
            GradeLevelPerformance(gradeLevel: "12", averageGrade: 86, targetGrade: 80)
        ]
    }
    
    // Generate mock data for student performance chart
    static func getStudentPerformanceData() -> [ChartDataPoint] {
        return [
            ChartDataPoint(label: "John Smith", value: 92),
            ChartDataPoint(label: "Emily Johnson", value: 88),
            ChartDataPoint(label: "Michael Williams", value: 76),
            ChartDataPoint(label: "Olivia Brown", value: 85),
            ChartDataPoint(label: "James Davis", value: 71),
            ChartDataPoint(label: "Sophia Miller", value: 79),
            ChartDataPoint(label: "Benjamin Wilson", value: 83),
            ChartDataPoint(label: "Ava Moore", value: 91)
        ]
    }
    
    // Generate mock data for attendance vs grades chart
    static func getAttendanceVsGradesData() -> [ScatterPlotDataPoint] {
        let students = MockDataService.shared.generateMockData().students
        var data: [ScatterPlotDataPoint] = []
        
        for student in students {
            // Generate realistic correlation between attendance and grades
            let attendance = Double.random(in: 75...98)
            // Base the grade somewhat on attendance to show correlation
            let baseGrade = attendance * 0.7
            // Add some randomness
            let finalGrade = min(max(baseGrade + Double.random(in: -10...20), 60), 100)
            
            data.append(ScatterPlotDataPoint(
                label: student.fullName,
                x: attendance,
                y: finalGrade
            ))
        }
        
        return data
    }
    
    // Generate mock data for radar chart
    static func getEngagementRadarData() -> [EngagementRadarChart.EngagementScore] {
        return [
            .init(category: "Participation", score: Double.random(in: 0.6...0.9), color: .blue),
            .init(category: "Assignment Completion", score: Double.random(in: 0.7...0.95), color: .green),
            .init(category: "Attendance", score: Double.random(in: 0.8...0.95), color: .orange),
            .init(category: "Peer Interaction", score: Double.random(in: 0.5...0.85), color: .purple),
            .init(category: "Critical Thinking", score: Double.random(in: 0.6...0.9), color: .pink)
        ]
    }
    
    // Generate mock data for attendance heatmap
    static func getAttendanceHeatMapData() -> [SpecialtyCharts.AttendanceHeatMap.AttendanceRecord] {
        var records: [SpecialtyCharts.AttendanceHeatMap.AttendanceRecord] = []
        let calendar = Calendar.current
        let today = Date()
        let startOfSemester = calendar.date(byAdding: .day, value: -60, to: today)!
        
        let statuses: [SpecialtyCharts.AttendanceHeatMap.AttendanceRecord.AttendanceStatus] = [
            .present, .present, .present, .present, .present, 
            .present, .late, .present, .present, .present, 
            .excused, .present, .present, .present, .present, 
            .late, .present, .unexcused, .present, .present
        ]
        
        for i in 0..<60 {
            let statusIndex = i % statuses.count
            let date = calendar.date(byAdding: .day, value: i, to: startOfSemester)!
            // Only add data for weekdays (no weekend attendance)
            let weekday = calendar.component(.weekday, from: date)
            if weekday >= 2 && weekday <= 6 { // Monday to Friday
                records.append(SpecialtyCharts.AttendanceHeatMap.AttendanceRecord(
                    date: date,
                    status: statuses[statusIndex]
                ))
            }
        }
        
        return records
    }
    
    // Generate mock insights
    static func getAnalyticsInsights() -> [AnalyticsInsight] {
        return [
            AnalyticsInsight(
                title: "Grade distribution improving",
                description: "5% more students in A-B range compared to last semester",
                icon: "arrow.up.right",
                color: .green
            ),
            AnalyticsInsight(
                title: "Assignment completion needs attention",
                description: "Late submissions increased 8% in the past two weeks",
                icon: "exclamationmark.triangle",
                color: .orange
            ),
            AnalyticsInsight(
                title: "High attendance correlation",
                description: "Students with >90% attendance have 18% higher grades on average",
                icon: "checkmark.circle",
                color: .blue
            )
        ]
    }
}