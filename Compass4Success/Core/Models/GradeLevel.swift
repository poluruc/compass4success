import Foundation

// Simplified model defining grade levels within the school system
public enum GradeLevel: String, CaseIterable, Equatable, Identifiable, Codable {
    case jk = "JK"
    case sk = "SK"
    
    // Elementary school
    case grade1 = "Grade 1"
    case grade2 = "Grade 2"
    case grade3 = "Grade 3"
    case grade4 = "Grade 4"
    case grade5 = "Grade 5"
    
    // Middle school
    case grade6 = "Grade 6"
    case grade7 = "Grade 7"
    case grade8 = "Grade 8"
    
    // High school
    case grade9 = "Grade 9"
    case grade10 = "Grade 10"
    case grade11 = "Grade 11"
    case grade12 = "Grade 12"
    
    
    public var id: String { self.rawValue }
    
    // Short name representation (e.g., "K", "1", "2", etc.)
    public var shortName: String {
        switch self {
        case .jk:
            return "JK"
        case .sk:
            return "SK"
        case .grade1, .grade2, .grade3, .grade4, .grade5, 
             .grade6, .grade7, .grade8, .grade9:
            // Remove "Grade " prefix and return the number
            return String(rawValue.dropFirst(6))
        case .grade10, .grade11, .grade12:
            return String(rawValue.dropFirst(6))
        }
    }
    
    // Education level grouping
    public var educationLevel: EducationLevel {
        switch self {
        case .jk, .sk, .grade1, .grade2, .grade3, .grade4, .grade5:
            return .elementary
        case .grade6, .grade7, .grade8:
            return .middle
        case .grade9, .grade10, .grade11, .grade12:
            return .high
        }
    }
    
    // Simple numeric value (0 for K, 1-12 for grades)
    public var numericValue: Int {
        switch self {
        case .jk:
            return 0
        case .sk:
            return 1
        case .grade1:
            return 2
        case .grade2:
            return 3
        case .grade3:
            return 4
        case .grade4:
            return 5
        case .grade5:
            return 6
        case .grade6:
            return 7
        case .grade7:
            return 8
        case .grade8:
            return 9
        case .grade9:
            return 9
        case .grade10:
            return 10
        case .grade11:
            return 11
        case .grade12:
            return 12
        }
    }
    
    // Factory method to get a grade level from a string or number
    public static func from(_ value: Any) -> GradeLevel {
        switch value {
        case let string as String:
            // Try to match the raw value first
            if let grade = GradeLevel(rawValue: string) {
                return grade
            }
            
            // Try to match based on common patterns
            let lowercased = string.lowercased()
            if lowercased.contains("jk") || lowercased == "jk" {
                return .jk
            } else if lowercased.contains("sk") || lowercased == "sk" {
                return .sk
            } else if lowercased.contains("grade 1") || lowercased == "grade1" || lowercased == "1" {
                return .grade1
            } else if lowercased.contains("grade 2") || lowercased == "grade2" || lowercased == "2" {
                return .grade2
            } else if lowercased.contains("grade 3") || lowercased == "grade3" || lowercased == "3" {
                return .grade3
            } else if lowercased.contains("grade 4") || lowercased == "grade4" || lowercased == "4" {
                return .grade4
            } else if lowercased.contains("grade 5") || lowercased == "grade5" || lowercased == "5" {
                return .grade5
            } else if lowercased.contains("grade 6") || lowercased == "grade6" || lowercased == "6" {
                return .grade6
            } else if lowercased.contains("grade 7") || lowercased == "grade7" || lowercased == "7" {
                return .grade7
            } else if lowercased.contains("grade 8") || lowercased == "grade8" || lowercased == "8" {
                return .grade8
            } else if lowercased.contains("grade 9") || lowercased == "grade9" || lowercased == "9" {
                return .grade9
            } else if lowercased.contains("grade 10") || lowercased == "grade10" || lowercased == "10" {
                return .grade10
            } else if lowercased.contains("grade 11") || lowercased == "grade11" || lowercased == "11" {
                return .grade11
            } else if lowercased.contains("grade 12") || lowercased == "grade12" || lowercased == "12" {
                return .grade12
            }
            
        case let int as Int:
            switch int {
            case 0:
                return .jk
            case 1:
                return .sk
            case 2:
                return .grade1
            case 3:
                return .grade2
            case 4:
                return .grade3
            case 5:
                return .grade4
            case 6:
                return .grade5
            case 7:
                return .grade6
            case 8:
                return .grade7
            case 9:
                return .grade8
            case 10:
                return .grade9
            case 11:
                return .grade10
            case 12:
                return .grade11
            case 13:
                return .grade12
            default:
                return .grade1
            }
        default:
            return .grade1
        }
        return .grade1
    }
    
    // Education level categories for grouping grade levels
    public enum EducationLevel: String, CaseIterable, Identifiable {
        case elementary = "Elementary School"
        case middle = "Middle School"
        case high = "High School"
        
        public var id: String { self.rawValue }
        
        // Get all grade levels that belong to this education level
        public var gradeLevels: [GradeLevel] {
            GradeLevel.allCases.filter { $0.educationLevel == self }
        }
    }
}
