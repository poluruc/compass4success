import Foundation
import RealmSwift

class Student: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var firstName: String = ""
    @Persisted var lastName: String = ""
    @Persisted var email: String = ""
    @Persisted var grade: String = ""
    @Persisted var studentNumber: String = ""
    @Persisted var dateOfBirth: Date? = nil
    @Persisted var guardianEmail: String = ""
    @Persisted var guardianPhone: String = ""
    @Persisted var createdAt: Date = Date()
    @Persisted var updatedAt: Date = Date()
    @Persisted var isActive: Bool = true
    @Persisted var courses = List<SchoolClass>()
    @Persisted var gender: String = ""
    
    // Computed property for GPA (to be compatible with the StudentViewModel)
    var gpa: Double {
        return averageGrade ?? 0.0
    }
    
    // Renamed to avoid conflicts
    var displayName: String {
        return "\(firstName) \(lastName)"
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    // Renamed to initials for clarity
    var initials: String {
        let firstInitial = firstName.first?.uppercased() ?? ""
        let lastInitial = lastName.first?.uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
    
    // Provide compatibility with code that expects student.name
    var name: String {
        return displayName
    }
    
    // Calculate average grade across all courses
    var averageGrade: Double? {
        if courses.isEmpty {
            return nil
        }
        
        var total = 0.0
        var count = 0
        
        for course in courses {
            if let grade = course.finalGrade {
                total += grade
                count += 1
            }
        }
        
        return count > 0 ? total / Double(count) : nil
    }
    
    // Format the average grade for display
    var formattedAverageGrade: String {
        if let avg = averageGrade {
            return String(format: "%.1f%%", avg)
        } else {
            return "N/A"
        }
    }
    
    // Letter grade based on average numerical grade
    var letterGrade: String {
        guard let average = averageGrade else {
            return "N/A"
        }
        
        switch average {
        case 90...100:
            return "A"
        case 80..<90:
            return "B"
        case 70..<80:
            return "C"
        case 60..<70:
            return "D"
        default:
            return "F"
        }
    }
}