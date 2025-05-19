import Foundation
import SwiftUI

// Mock data generator for analytics-related testing and previews
struct AnalyticsMockData {
    static func generateMockStudents(count: Int = 25) -> [Student] {
        let mockDataService = MockDataService.shared
        return Array(mockDataService.generateMockData().students.prefix(count))
    }
    
    static func generateMockClasses(count: Int = 5) -> [SchoolClass] {
        let mockDataService = MockDataService.shared
        return Array(mockDataService.generateMockData().classes.prefix(count))
    }
    
    static func generateMockGrades(for student: Student, count: Int = 6) -> [Grade] {
        var grades: [Grade] = []
        
        for i in 0..<count {
            let score = Double.random(in: 60...100)
            
            let grade = Grade()
            grade.id = UUID().uuidString
            grade.studentId = student.id
            grade.assignmentId = "assignment_\(i)"
            grade.score = score
            grade.maxScore = 100
            grade.submittedDate = Date().addingTimeInterval(Double(-i * 86400))
            grade.gradedDate = Date().addingTimeInterval(Double(-i * 86400) + 86400)
            grade.comments = ["Good work!", "Needs improvement", "Excellent!", "Keep practicing", "Nice effort"].randomElement()!
            
            grades.append(grade)
        }
        
        return grades
    }
    
    static func generateMockAssignments(for schoolClass: SchoolClass, count: Int = 8) -> [Assignment] {
        var assignments: [Assignment] = []
        
        let assignmentTypes = ["Homework", "Quiz", "Project", "Test", "Essay", "Lab", "Presentation"]
        let calendar = Calendar.current
        let today = Date()
        
        for i in 0..<count {
            let dueDate = calendar.date(byAdding: .day, value: -i * 7, to: today)!
            
            let assignment = Assignment()
            assignment.id = "assignment_\(schoolClass.id)_\(i)"
            assignment.classId = schoolClass.id
            assignment.title = "\(assignmentTypes.randomElement()!) \(i + 1)"
            assignment.assignmentDescription = "Description for assignment \(i + 1)"
            assignment.dueDate = dueDate
            assignment.points = Double([10, 25, 50, 100].randomElement()!)
            
            assignments.append(assignment)
        }
        
        return assignments
    }
    
    static func generateMockSubmissions(for assignment: Assignment, students: [Student]) -> [Submission] {
        var submissions: [Submission] = []
        
        for student in students {
            let submitDate = Date().addingTimeInterval(Double.random(in: -86400 * 7...0))
            let isLate = submitDate > assignment.dueDate
            let isSubmitted = Double.random(in: 0...1) < 0.9 // 90% submission rate
            
            if isSubmitted {
                let submission = Submission()
                submission.id = UUID().uuidString
                submission.assignmentId = assignment.id
                submission.studentId = student.id
                submission.submittedDate = submitDate
                submission.status = isLate ? "late" : "submitted"
                
                submissions.append(submission)
            }
        }
        
        return submissions
    }
    
    static func generateMockGradeDistribution() -> [Int] {
        return [
            Int.random(in: 3...8),   // A
            Int.random(in: 5...12),  // B
            Int.random(in: 4...10),  // C
            Int.random(in: 2...6),   // D
            Int.random(in: 0...3)    // F
        ]
    }
    
    static func generateMockAttendanceData(days: Int = 30) -> [Date: String] {
        var attendanceData: [Date: String] = [:]
        let attendanceStatus = ["present", "present", "present", "present", "present", "present", "present", "present", "late", "excused", "unexcused"]
        
        let calendar = Calendar.current
        let today = Date()
        
        for i in 0..<days {
            let day = calendar.date(byAdding: .day, value: -i, to: today)!
            let weekday = calendar.component(.weekday, from: day)
            
            // Only include weekdays (Monday-Friday)
            if weekday >= 2 && weekday <= 6 {
                let status = attendanceStatus.randomElement()!
                attendanceData[day] = status
            }
        }
        
        return attendanceData
    }
    
    static func generateMockRubricScores() -> [RubricScore] {
        // This is a simplified version - in a real app, you would create actual rubrics
        // and associate them with assignments, then generate scores accordingly
        let mockScores: [RubricScore] = []
        return mockScores
    }
}
