import Foundation
import Combine
import SwiftUI

class DashboardViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: Error?
    @Published var quickStats: [QuickStat] = []
    @Published var upcomingAssignments: [Assignment] = []
    @Published var recentActivities: [Activity] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let mockService = MockDataService.shared
    
    init() {
        loadData()
    }
    
    func loadData() {
        isLoading = true
        
        // Generate mock data using the MockDataService
        let mockData = mockService.generateMockData()
        
        // In a real app, these would come from various services
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.quickStats = [
                QuickStat(id: "1", title: "Students", value: "\(mockData.students.count)", icon: "person.3", trend: "+3%", trendDirection: .up),
                QuickStat(id: "2", title: "Classes", value: "\(mockData.classes.count)", icon: "book", trend: "", trendDirection: .none),
                QuickStat(id: "3", title: "Assignments", value: "24", icon: "doc.text", trend: "+2", trendDirection: .up),
                QuickStat(id: "4", title: "Avg. Grade", value: "76%", icon: "chart.bar", trend: "-2%", trendDirection: .down)
            ]
            
            // Create upcoming assignments with due dates in the future
            let currentDate = Date()
            self.upcomingAssignments = [
                Assignment(id: "1", title: "Math Problem Set #5", dueDate: currentDate.addingTimeInterval(86400), // Tomorrow
                          description: "Complete problems 1-20 in Chapter 5", submissions: []),
                Assignment(id: "2", title: "History Essay", dueDate: currentDate.addingTimeInterval(86400 * 3), // 3 days
                          description: "2000 word essay on the Industrial Revolution", submissions: []),
                Assignment(id: "3", title: "Science Lab Report", dueDate: currentDate.addingTimeInterval(86400 * 5), // 5 days
                          description: "Write up findings from yesterday's chemistry experiment", submissions: []),
                Assignment(id: "4", title: "Group Project Milestone", dueDate: currentDate.addingTimeInterval(86400 * 7), // 1 week
                          description: "Submit initial design documents for review", submissions: [])
            ]
            
            self.recentActivities = [
                Activity(id: "1", title: "Grade Update", description: "Science Quiz 2 grades posted", timestamp: Date().addingTimeInterval(-3600), icon: "doc.text.fill", type: .gradeUpdate),
                Activity(id: "2", title: "New Assignment", description: "Math Project assigned", timestamp: Date().addingTimeInterval(-7200), icon: "plus.circle.fill", type: .newAssignment),
                Activity(id: "3", title: "Student Added", description: "Emma Johnson added to Class 3B", timestamp: Date().addingTimeInterval(-86400), icon: "person.badge.plus", type: .studentUpdate)
            ]
            
            self.isLoading = false
        }
    }
    
    func reloadData() {
        isLoading = true
        
        // Generate mock data using the MockDataService
        let mockData = mockService.generateMockData()
        let randomStudentsCount = Int.random(in: 8...15)
        let randomClassesCount = Int.random(in: 4...8)
        let randomAssignmentsCount = Int.random(in: 18...30)
        let randomAvgGrade = Int.random(in: 68...92)
        
        // Generate random trend data
        let studentsTrend = Int.random(in: -5...5)
        let assignmentsTrend = Int.random(in: -3...3)
        let gradeTrend = Double.random(in: -5...5).rounded() / 10.0
        
        // In a real app, this would refresh data from the backend
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            // Update stats with randomized data
            self.quickStats = [
                QuickStat(id: "1", title: "Students", 
                          value: "\(randomStudentsCount)", 
                          icon: "person.3", 
                          trend: studentsTrend > 0 ? "+\(studentsTrend)" : "\(studentsTrend)", 
                          trendDirection: studentsTrend > 0 ? .up : (studentsTrend < 0 ? .down : .none)),
                QuickStat(id: "2", title: "Classes", 
                          value: "\(randomClassesCount)", 
                          icon: "book", 
                          trend: "", 
                          trendDirection: .none),
                QuickStat(id: "3", title: "Assignments", 
                          value: "\(randomAssignmentsCount)", 
                          icon: "doc.text", 
                          trend: assignmentsTrend > 0 ? "+\(assignmentsTrend)" : "\(assignmentsTrend)", 
                          trendDirection: assignmentsTrend > 0 ? .up : (assignmentsTrend < 0 ? .down : .none)),
                QuickStat(id: "4", title: "Avg. Grade", 
                          value: "\(randomAvgGrade)%", 
                          icon: "chart.bar", 
                          trend: gradeTrend > 0 ? "+\(String(format: "%.1f", gradeTrend))%" : "\(String(format: "%.1f", gradeTrend))%", 
                          trendDirection: gradeTrend > 0 ? .up : (gradeTrend < 0 ? .down : .none))
            ]
            
            // Randomize activity order and times
            let timeIntervals = [-1800, -3600, -7200, -14400, -28800, -43200, -86400]
            let randomActivityTimes = timeIntervals.shuffled().prefix(3)
            var activityIndex = 0
            
            self.recentActivities = [
                Activity(id: "1", title: "Grade Update", 
                         description: "Science Quiz 2 grades posted", 
                         timestamp: Date().addingTimeInterval(randomActivityTimes[activityIndex]), 
                         icon: "doc.text.fill", 
                         type: .gradeUpdate),
                Activity(id: "2", title: "New Assignment", 
                         description: "Math Project assigned", 
                         timestamp: Date().addingTimeInterval(randomActivityTimes[activityIndex + 1]), 
                         icon: "plus.circle.fill", 
                         type: .newAssignment),
                Activity(id: "3", title: "Student Added", 
                         description: "Emma Johnson added to Class 3B", 
                         timestamp: Date().addingTimeInterval(randomActivityTimes[activityIndex + 2]), 
                         icon: "person.badge.plus", 
                         type: .studentUpdate)
            ]
            
            self.isLoading = false
        }
    }
    
    // Alias for reloadData to match the function name used in DashboardView
    func loadDashboardData() {
        reloadData()
    }
    
    // Filter assignments based on selected time range
    func filterAssignmentsByTimeRange(timeRange: String, assignments: [Assignment]) -> [Assignment] {
        let currentDate = Date()
        let calendar = Calendar.current
        
        switch timeRange {
        case "Week":
            // Filter for assignments due within the next 7 days
            return assignments.filter { assignment in
                let components = calendar.dateComponents([.day], from: currentDate, to: assignment.dueDate)
                return (components.day ?? 0) <= 7
            }
        case "Month":
            // Filter for assignments due within the next 30 days
            return assignments.filter { assignment in
                let components = calendar.dateComponents([.day], from: currentDate, to: assignment.dueDate)
                return (components.day ?? 0) <= 30
            }
        case "Semester":
            // Filter for assignments due within the next 120 days (approximately a semester)
            return assignments.filter { assignment in
                let components = calendar.dateComponents([.day], from: currentDate, to: assignment.dueDate)
                return (components.day ?? 0) <= 120
            }
        case "Year":
            // Filter for assignments due within the next 365 days
            return assignments.filter { assignment in
                let components = calendar.dateComponents([.day], from: currentDate, to: assignment.dueDate)
                return (components.day ?? 0) <= 365
            }
        default:
            return assignments
        }
    }
}

// Models for the dashboard
struct QuickStat: Identifiable {
    var id: String
    var title: String
    var value: String
    var icon: String
    var trend: String
    var trendDirection: TrendDirection
    
    enum TrendDirection {
        case up, down, none
        
        var color: Color {
            switch self {
            case .up:
                return .green
            case .down:
                return .red
            case .none:
                return .gray
            }
        }
        
        var icon: String {
            switch self {
            case .up:
                return "arrow.up"
            case .down:
                return "arrow.down"
            case .none:
                return ""
            }
        }
    }
}

struct Activity: Identifiable {
    var id: String
    var title: String
    var description: String
    var timestamp: Date
    var icon: String
    var type: ActivityType
    
    enum ActivityType {
        case gradeUpdate, newAssignment, studentUpdate, systemNotice
        
        var color: Color {
            switch self {
            case .gradeUpdate:
                return .blue
            case .newAssignment:
                return .green
            case .studentUpdate:
                return .orange
            case .systemNotice:
                return .gray
            }
        }
    }
}