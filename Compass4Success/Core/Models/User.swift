import Foundation
import RealmSwift
import SwiftUI

// Primary user model for authentication and identification
class User: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var email: String = ""
    @Persisted var username: String = ""
    @Persisted var firstName: String = ""
    @Persisted var lastName: String = ""
    @Persisted var profileImageUrl: String?
    @Persisted var role: String = UserRole.student.rawValue
    @Persisted var lastLogin: Date?
    @Persisted var createdAt: Date = Date()
    @Persisted var isActive: Bool = true
    @Persisted var schoolId: String?
    @Persisted var districtId: String?
    @Persisted var gradeLevel: String?
    @Persisted var preferences = Map<String, String>()
    
    // Computed property for full name
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    // Role as enum
    var roleEnum: UserRole {
        get {
            return UserRole(rawValue: role) ?? .student
        }
        set {
            role = newValue.rawValue
        }
    }
    
    // Computed property for user initials
    var initials: String {
        let firstInitial = firstName.first.map(String.init) ?? ""
        let lastInitial = lastName.first.map(String.init) ?? ""
        return (firstInitial + lastInitial).uppercased()
    }
    
    // Convenience initializer
    convenience init(email: String, firstName: String, lastName: String, role: UserRole = .student) {
        self.init()
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.roleEnum = role
        self.username = email
    }
    
    // Helper method to set user preferences
    func setPreference(key: String, value: String) {
        preferences[key] = value
    }
    
    // Helper method to get user preferences
    func getPreference(key: String) -> String? {
        return preferences[key]
    }
    
    // Check if user has a specific permission
    func hasPermission(_ permission: UserPermission) -> Bool {
        return roleEnum.permissions.contains(permission)
    }
}

// Enumeration of user roles
enum UserRole: String, CaseIterable {
    case student = "Student"
    case teacher = "Teacher"
    case admin = "Administrator"
    case parent = "Parent/Guardian"
    case counselor = "Counselor"
    case districtAdmin = "District Administrator"
    case it = "IT Support"
    case guest = "Guest"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .student:
            return "person.fill"
        case .teacher:
            return "person.fill.viewfinder"
        case .admin:
            return "building.2.fill"
        case .parent:
            return "person.2.fill"
        case .counselor:
            return "heart.text.square.fill"
        case .districtAdmin:
            return "building.columns.fill"
        case .it:
            return "laptopcomputer"
        case .guest:
            return "person.fill.questionmark"
        }
    }
    
    var color: Color {
        switch self {
        case .student:
            return .blue
        case .teacher:
            return .green
        case .admin:
            return .purple
        case .parent:
            return .orange
        case .counselor:
            return .pink
        case .districtAdmin:
            return .indigo
        case .it:
            return .gray
        case .guest:
            return .secondary
        }
    }
    
    var permissions: [UserPermission] {
        switch self {
        case .student:
            return [.viewOwnData, .submitAssignments]
        case .teacher:
            return [.viewStudentData, .createAssignments, .gradeAssignments, 
                    .viewAnalytics, .exportClassReports, .manageClasses]
        case .admin:
            return UserPermission.allCases
        case .parent:
            return [.viewOwnChildData]
        case .counselor:
            return [.viewStudentData, .viewAnalytics, .exportReports, .manageStudents]
        case .districtAdmin:
            return UserPermission.allCases
        case .it:
            return [.manageUsers, .viewLogs, .systemConfiguration]
        case .guest:
            return [.viewPublicData]
        }
    }
}

// User permissions enum
enum UserPermission: String, CaseIterable {
    // Student permissions
    case viewOwnData = "View Own Data"
    case submitAssignments = "Submit Assignments"
    
    // Teacher permissions
    case viewStudentData = "View Student Data"
    case createAssignments = "Create Assignments"
    case gradeAssignments = "Grade Assignments"
    case viewAnalytics = "View Analytics"
    case exportClassReports = "Export Class Reports"
    case manageClasses = "Manage Classes"
    
    // Admin permissions
    case manageUsers = "Manage Users"
    case manageSchool = "Manage School"
    case manageStudents = "Manage Students"
    case manageTeachers = "Manage Teachers"
    case exportReports = "Export Reports"
    case viewLogs = "View Logs"
    case systemConfiguration = "System Configuration"
    
    // Parent permissions
    case viewOwnChildData = "View Own Child Data"
    
    // Public permissions
    case viewPublicData = "View Public Data"
}

// User settings and preferences
class UserSettings: Object, Identifiable {
    @Persisted(primaryKey: true) var userId: String = ""
    @Persisted var theme: String = "system"
    @Persisted var notificationsEnabled: Bool = true
    @Persisted var emailNotificationsEnabled: Bool = true
    @Persisted var gradeViewFormat: String = "percentage"
    @Persisted var dashboardLayout: String = "standard"
    @Persisted var language: String = "en"
    @Persisted var accessibilityOptions = Map<String, Bool>()
    
    var themeMode: ThemeMode {
        get {
            return ThemeMode(rawValue: theme) ?? .system
        }
        set {
            theme = newValue.rawValue
        }
    }
    
    var gradeFormat: GradeFormat {
        get {
            return GradeFormat(rawValue: gradeViewFormat) ?? .percentage
        }
        set {
            gradeViewFormat = newValue.rawValue
        }
    }
    
    var layoutPreference: LayoutPreference {
        get {
            return LayoutPreference(rawValue: dashboardLayout) ?? .standard
        }
        set {
            dashboardLayout = newValue.rawValue
        }
    }
    
    // Convenience initializer
    convenience init(userId: String) {
        self.init()
        self.userId = userId
    }
    
    // Set accessibility option
    func setAccessibilityOption(_ option: AccessibilityOption, enabled: Bool) {
        accessibilityOptions[option.rawValue] = enabled
    }
    
    // Check if accessibility option is enabled
    func isAccessibilityOptionEnabled(_ option: AccessibilityOption) -> Bool {
        return accessibilityOptions[option.rawValue] ?? false
    }
}

// Theme mode enum
enum ThemeMode: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
}

// Grade display format enum
enum GradeFormat: String, CaseIterable {
    case percentage = "percentage"
    case letter = "letter"
    case points = "points"
    case achievementLevel = "achievementLevel"
}

// Layout preference enum
enum LayoutPreference: String, CaseIterable {
    case standard = "standard"
    case compact = "compact"
    case detailed = "detailed"
    case customized = "customized"
}

// Accessibility option enum
enum AccessibilityOption: String, CaseIterable {
    case largeText = "largeText"
    case highContrast = "highContrast"
    case reduceMotion = "reduceMotion"
    case voiceOver = "voiceOver"
    case screenReader = "screenReader"
}