import Foundation
import SwiftUI
import RealmSwift

// MARK: - Assignment Category

/// Defines different types of assignments that can be created

// MARK: - Assignment Extensions

extension Assignment {
    /// Get submissions for this assignment
    /// This is a placeholder - in a real app, you would query Realm for submissions
    private func getSubmissions() -> [AssignmentSubmission] {
        // Mock implementation - would be replaced with Realm queries in production
        return []
    }
    
    /// Calculate the average grade for an assignment
    var averageGrade: Double {
        let submissions = getSubmissions()
        guard !submissions.isEmpty else { return 0.0 }
        
        let total = submissions.reduce(into: 0.0) { result, submission in
            result += submission.grade
        }
        return total / Double(submissions.count)
    }
    
    /// Calculate the submission rate for an assignment
    var submissionRate: Double {
        let submissions = getSubmissions()
        // This is just a placeholder - would need to know the total number of students to calculate accurately
        // Here we assume 25 students in the class as a dummy value
        let totalStudents = 25
        return Double(submissions.count) / Double(totalStudents)
    }
    
    /// Get the category of the assignment as an enum
    var assignmentCategory: AssignmentCategory {
        return AssignmentCategory(rawValue: category) ?? .assignment
    }
    
    /// Get the color associated with the assignment category
    var categoryColor: Color {
        return assignmentCategory.color
    }
    
    /// Get the icon associated with the assignment category
    var categoryIcon: String {
        return assignmentCategory.icon
    }
    
    /// Check if an assignment is due soon (within the next 3 days)
    var isDueSoon: Bool {
        let threeDaysFromNow = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        return dueDate > Date() && dueDate <= threeDaysFromNow && isActive
    }
    
    /// Get the submission status text
    var statusText: String {
        if !isActive {
            return "Completed"
        } else if dueDate < Date() {
            return "Past Due"
        } else if isDueSoon {
            return "Due Soon"
        } else {
            return "Active"
        }
    }

    
    /// Format the days remaining in a user-friendly way
    var formattedDaysRemaining: String {
        if !isActive {
            return "Completed"
        }
        
        let days = daysUntilDue
        
        if days < 0 {
            return "Overdue by \(abs(days)) day\(abs(days) == 1 ? "" : "s")"
        } else if days == 0 {
            return "Due today"
        } else if days == 1 {
            return "Due tomorrow"
        } else {
            return "Due in \(days) days"
        }
    }
    
    /// Get a color representing the urgency of the assignment
    var urgencyColor: Color {
        if !isActive {
            return .gray
        } else if daysUntilDue < 0 {
            return .red
        } else if daysUntilDue <= 1 {
            return .orange
        } else if daysUntilDue <= 3 {
            return .yellow
        } else {
            return .green
        }
    }
}

// MARK: - Assignment Submission Extensions

extension AssignmentSubmission {
    /// Format the submission date in a readable way
    var formattedSubmissionDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: submissionDate)
    }
    
    /// Calculate days late for a submission
    func daysLate(assignmentDueDate: Date) -> Int {
        guard submissionDate > assignmentDueDate else { return 0 }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: assignmentDueDate, to: submissionDate)
        return components.day ?? 0
    }
    
    /// Get a color representing the grade
    var gradeColor: Color {
        if grade >= 90 {
            return .green
        } else if grade >= 80 {
            return .blue
        } else if grade >= 70 {
            return .yellow
        } else if grade >= 60 {
            return .orange
        } else {
            return .red
        }
    }
}
