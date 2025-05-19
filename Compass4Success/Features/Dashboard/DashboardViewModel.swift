import Foundation
import Combine
import SwiftUI
import Compass4Success

class DashboardViewModel: ObservableObject {
    private let mockService = MockDataService.shared
    
    @Published var isLoading = false
    @Published var error: Error?
    @Published var quickStats: [QuickStat] = []
    @Published var upcomingAssignments: [Assignment] = []
    @Published var recentActivities: [ActivityItem] = []
    @Published var announcements: [Announcement] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadDashboardData()
    }
    
    func loadDashboardData() {
        isLoading = true
        
        // In a real app, these would come from various services
        let task = DispatchWorkItem {
            // Use the mockData to ensure it's not reported as unused
            _ = self.mockService.generateMockData()
            let randomStudentsCount = Int.random(in: 8...15)
            let randomClassesCount = Int.random(in: 4...8)
            
            self.quickStats = [
                QuickStat(
                    title: "Students",
                    value: "\(randomStudentsCount)",
                    description: "Total students in your classes",
                    icon: "person.3",
                    color: .blue
                ),
                QuickStat(
                    title: "Classes",
                    value: "\(randomClassesCount)",
                    description: "Active classes this semester",
                    icon: "book",
                    color: .purple
                ),
                QuickStat(
                    title: "Assignments",
                    value: "\(Int.random(in: 15...30))",
                    description: "Upcoming assignments",
                    icon: "list.clipboard",
                    color: .orange
                ),
                QuickStat(
                    title: "Analytics",
                    value: "\(Int.random(in: 75...95))%",
                    description: "Average grade across classes",
                    icon: "chart.bar",
                    color: .green
                )
            ]
            
            // Generate upcoming assignments
            self.upcomingAssignments = (0..<4).map { i in
                let assignment = Assignment()
                assignment.id = "a\(i)"
                assignment.title = "Assignment \(i + 1)"
                assignment.assignmentDescription = "Description for assignment \(i + 1)"
                assignment.dueDate = Date().addingTimeInterval(TimeInterval(86400 * (i + 1)))
                return assignment
            }
            
            // Generate activity feed
            // Use activityTypes in the actual activities to avoid unused variable warnings
            let availableActivityTypes = [
                ("Grade Posted", "math.function", Color.green),
                ("Assignment Created", "plus.circle", Color.blue),
                ("Student Added", "person.badge.plus", Color.purple),
                ("Comment Added", "text.bubble", Color.orange),
                ("Class Created", "folder.badge.plus", Color.teal),
                ("Report Generated", "doc.text", Color.gray)
            ]
            
            let timeIntervals = [-1800.0, -3600.0, -7200.0, -14400.0, -28800.0, -43200.0, -86400.0]
            let randomActivityTimes = timeIntervals.shuffled().prefix(3).map { Double($0) }
            
            self.recentActivities = [
                ActivityItem(
                    title: "New Assignment Created",
                    description: "You created 'Final Project' for Mathematics",
                    timestamp: Date().addingTimeInterval(randomActivityTimes[0]),
                    icon: "plus.circle",
                    color: .blue
                ),
                ActivityItem(
                    title: "Grade Posted",
                    description: "You graded 12 submissions for 'Quiz 2'",
                    timestamp: Date().addingTimeInterval(randomActivityTimes[1]),
                    icon: "checkmark.circle",
                    color: .green
                ),
                ActivityItem(
                    title: "Student Added",
                    description: "New student 'Alex Johnson' added to your class",
                    timestamp: Date().addingTimeInterval(randomActivityTimes[2]),
                    icon: "person.badge.plus",
                    color: .purple
                )
            ]
            
            // Generate announcements
            self.announcements = [
                Announcement(
                    title: "End of Semester Approaching",
                    content: "Please submit all final grades by June 15th. Contact administration if you need an extension.",
                    date: Date().addingTimeInterval(-86400),
                    author: "Principal Davis",
                    priority: .high
                ),
                Announcement(
                    title: "Professional Development Day",
                    content: "Join us for teacher training sessions on May 20th. Various workshops will be available.",
                    date: Date().addingTimeInterval(-172800),
                    author: "Admin Team",
                    priority: .normal
                ),
                Announcement(
                    title: "New Gradebook Features",
                    content: "We've added new analytics tools to help track student progress. Check the updated documentation.",
                    date: Date().addingTimeInterval(-259200),
                    author: "IT Department",
                    priority: .normal
                )
            ]
            
            self.isLoading = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: task)
    }
    
    func refreshData() {
        // In a real app, this would refresh data from the backend
        let task = DispatchWorkItem {
            // Update stats with randomized data
            self.quickStats = [
                QuickStat(
                    title: "Students",
                    value: "\(Int.random(in: 8...15))", 
                    description: "Total students in your classes", 
                    icon: "person.3",
                    color: .blue
                ),
                QuickStat(
                    title: "Classes",
                    value: "\(Int.random(in: 4...8))",
                    description: "Active classes this semester",
                    icon: "book",
                    color: .purple
                ),
                QuickStat(
                    title: "Assignments",
                    value: "\(Int.random(in: 15...30))",
                    description: "Upcoming assignments",
                    icon: "list.clipboard",
                    color: .orange
                ),
                QuickStat(
                    title: "Analytics", 
                    value: "\(Int.random(in: 75...95))%",
                    description: "Average grade across classes",
                    icon: "chart.bar",
                    color: .green
                )
            ]
            
            // Generate new assignments with updated due dates
            self.upcomingAssignments = self.upcomingAssignments.enumerated().map { i, assignment in
                let updatedAssignment = assignment
                updatedAssignment.dueDate = Date().addingTimeInterval(TimeInterval(86400 * (i + 1)))
                return updatedAssignment
            }
            
            self.isLoading = false
        }
        
        self.isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
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
