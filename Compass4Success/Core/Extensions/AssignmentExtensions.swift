import Foundation
import SwiftUI

// MARK: - Assignment Category

/// Defines different types of assignments that can be created
enum AssignmentCategory: String, CaseIterable {
    case assignment = "Assignment"
    case quiz = "Quiz"
    case test = "Test"
    case project = "Project"
    case presentation = "Presentation"
    case lab = "Lab Report"
    case essay = "Essay"
    case homework = "Homework"
    case midterm = "Midterm Exam"
    case final = "Final Exam"
    
    var color: Color {
        switch self {
        case .assignment:
            return .blue
        case .quiz:
            return .green
        case .test:
            return .orange
        case .project:
            return .purple
        case .presentation:
            return .pink
        case .lab:
            return .teal
        case .essay:
            return .indigo
        case .homework:
            return .mint
        case .midterm, .final:
            return .red
        }
    }
    
    var icon: String {
        switch self {
        case .assignment:
            return "doc.text"
        case .quiz:
            return "checkmark.square"
        case .test:
            return "doc.text.magnifyingglass"
        case .project:
            return "folder"
        case .presentation:
            return "person.wave.2"
        case .lab:
            return "testtube.2"
        case .essay:
            return "text.quote"
        case .homework:
            return "house"
        case .midterm, .final:
            return "clock"
        }
    }
}

// MARK: - Assignment Extensions

extension Assignment {
    /// Calculate the average grade for an assignment
    var averageGrade: Double {
        guard !submissions.isEmpty else { return 0.0 }
        
        let total = submissions.reduce(0.0) { $0 + $1.grade }
        return total / Double(submissions.count)
    }
    
    /// Calculate the submission rate for an assignment
    var submissionRate: Double {
        // This is just a placeholder - would need to know the total number of students to calculate accurately
        // Here we assume 25 students in the class as a dummy value
        let totalStudents = 25
        return Double(submissions.count) / Double(totalStudents)
    }
    
    /// Format the assignment due date in a readable way
    var formattedDueDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: dueDate)
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
    
    /// Check if an assignment is past due
    var isPastDue: Bool {
        return dueDate < Date() && isActive
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
    
    /// Calculate days remaining until due date
    var daysUntilDue: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: dueDate)
        return components.day ?? 0
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
    
    /// Format the grade as a letter grade
    var letterGrade: String {
        if grade >= 90 {
            return "A"
        } else if grade >= 80 {
            return "B"
        } else if grade >= 70 {
            return "C"
        } else if grade >= 60 {
            return "D"
        } else {
            return "F"
        }
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