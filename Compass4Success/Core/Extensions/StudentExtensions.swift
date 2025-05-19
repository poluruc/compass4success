import Foundation
import SwiftUI

// MARK: - Student Extensions

extension Student {
    /// Get the full name of the student
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    /// Get the display name (last name, first name) for sorting and formal display
    var displayName: String {
        return "\(lastName), \(firstName)"
    }
    
    /// Get the student's initials
    var initials: String {
        let firstInitial = firstName.prefix(1).uppercased()
        let lastInitial = lastName.prefix(1).uppercased()
        return "\(firstInitial)\(lastInitial)"
    }
    
    /// Generate a profile image color based on the student's name
    var profileColor: Color {
        // Generate a consistent color based on the hash of the student's name
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .teal, .indigo, .mint, .red, .yellow]
        let nameHash = (firstName + lastName).hash
        let index = abs(nameHash) % colors.count
        return colors[index]
    }
    
    /// Calculate the current GPA if not already set
    var calculatedGPA: Double {
        // If GPA is already set, return it
        if gpa > 0 {
            return gpa
        }
        
        // Calculate based on courses if available
        guard !courses.isEmpty else { return 0.0 }
        
        var totalPoints = 0.0
        var totalCourses = 0
        
        for course in courses {
            if let finalGrade = course.finalGrade {
                totalPoints += finalGrade
                totalCourses += 1
            }
        }
        
        return totalCourses > 0 ? (totalPoints / Double(totalCourses)) / 25.0 : 0.0 // Convert percentage to 4.0 scale
    }
    
    /// Format the GPA to a string with 2 decimal places
    var formattedGPA: String {
        return String(format: "%.2f", calculatedGPA)
    }
    
    /// Get the letter grade equivalent of the GPA
    var letterGrade: String {
        let gpa = calculatedGPA
        
        if gpa >= 3.7 {
            return "A"
        } else if gpa >= 3.3 {
            return "A-"
        } else if gpa >= 3.0 {
            return "B+"
        } else if gpa >= 2.7 {
            return "B"
        } else if gpa >= 2.3 {
            return "B-"
        } else if gpa >= 2.0 {
            return "C+"
        } else if gpa >= 1.7 {
            return "C"
        } else if gpa >= 1.3 {
            return "C-"
        } else if gpa >= 1.0 {
            return "D"
        } else {
            return "F"
        }
    }
    
    /// Get the color associated with the student's academic standing
    var academicStandingColor: Color {
        let gpa = calculatedGPA
        
        if gpa >= 3.5 {
            return .green
        } else if gpa >= 3.0 {
            return .blue
        } else if gpa >= 2.0 {
            return .yellow
        } else if gpa >= 1.0 {
            return .orange
        } else {
            return .red
        }
    }
    
    /// Check if a student is enrolled in a specific class
    func isEnrolledIn(classId: String) -> Bool {
        return enrollments.contains { $0.classId == classId }
    }
    
    /// Calculate the percentage of assignments completed for a class
    func completionRate(forClassId classId: String, assignments: [Assignment]) -> Double {
        let classAssignments = assignments.filter { $0.classId == classId }
        guard !classAssignments.isEmpty else { return 0.0 }
        
        var completed = 0
        
        for assignment in classAssignments {
            if assignment.submissions.contains(where: { $0.studentId == id }) {
                completed += 1
            }
        }
        
        return Double(completed) / Double(classAssignments.count)
    }
    
    /// Calculate the average grade for a specific class
    func averageGrade(forClassId classId: String, assignments: [Assignment]) -> Double {
        let classAssignments = assignments.filter { $0.classId == classId }
        var totalPoints = 0.0
        var earnedPoints = 0.0
        
        for assignment in classAssignments {
            if let submission = assignment.submissions.first(where: { $0.studentId == id }) {
                totalPoints += Double(assignment.totalPoints)
                earnedPoints += submission.grade * Double(assignment.totalPoints) / 100.0
            }
        }
        
        return totalPoints > 0 ? (earnedPoints / totalPoints) * 100.0 : 0.0
    }
    
    /// Get the current grade level as an ordinal string (e.g., "9th Grade")
    var gradeOrdinal: String {
        guard let gradeNumber = Int(grade) else {
            // Handle special cases like "K" for kindergarten
            if grade == "K" {
                return "Kindergarten"
            }
            return "\(grade) Grade"
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        
        if let ordinal = numberFormatter.string(from: NSNumber(value: gradeNumber)) {
            return "\(ordinal) Grade"
        }
        
        return "\(grade) Grade"
    }
    
    /// Calculate age based on date of birth (if available)
    var age: Int? {
        guard let dateOfBirth = dateOfBirth else {
            return nil
        }
        
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year
    }
    
    /// Check if student has missing assignments
    func hasMissingAssignments(assignments: [Assignment]) -> Bool {
        for assignment in assignments {
            if assignment.isActive && !assignment.submissions.contains(where: { $0.studentId == id }) {
                return true
            }
        }
        return false
    }
    
    /// Count the number of missing assignments
    func missingAssignmentsCount(assignments: [Assignment]) -> Int {
        var count = 0
        for assignment in assignments {
            if assignment.isActive && !assignment.submissions.contains(where: { $0.studentId == id }) {
                count += 1
            }
        }
        return count
    }
}

// MARK: - StudentClassEnrollment Extensions

extension StudentClassEnrollment {
    /// Format the enrollment date in a readable way
    var formattedEnrollmentDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: enrollmentDate)
    }
    
    /// Calculate how long the student has been enrolled in the class
    var enrollmentDuration: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: enrollmentDate, to: Date())
        
        if let year = components.year, year > 0 {
            return "\(year) year\(year == 1 ? "" : "s")"
        } else if let month = components.month, month > 0 {
            return "\(month) month\(month == 1 ? "" : "s")"
        } else if let day = components.day, day > 0 {
            return "\(day) day\(day == 1 ? "" : "s")"
        } else {
            return "Today"
        }
    }
}