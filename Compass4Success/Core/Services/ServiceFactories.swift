import Foundation
import SwiftUI

// Service factory protocol for dependency injection
protocol ServiceFactory {
    // Authentication
    func makeAuthenticationService() -> AuthenticationService
    
    // Data services
    func makeClassService() -> ClassService
    func makeStudentService() -> StudentService
    func makeAssignmentService() -> AssignmentService
    func makeGradebookService() -> GradebookService
    func makeAnalyticsService() -> AnalyticsService
    func makeCurriculumService() -> CurriculumService
    
    // Utility services
    func makeNotificationService() -> NotificationService
    func makeExportService() -> ExportService
    func makeLogService() -> LogService
}

// Production service factory that creates real service implementations
class ProductionServiceFactory: ServiceFactory {
    // Singleton pattern
    static let shared = ProductionServiceFactory()
    
    private init() {}
    
    // Authentication service
    func makeAuthenticationService() -> AuthenticationService {
        return AuthenticationService()
    }
    
    // Data services
    func makeClassService() -> ClassService {
        return ClassService()
    }
    
    func makeStudentService() -> StudentService {
        return StudentService()
    }
    
    func makeAssignmentService() -> AssignmentService {
        return AssignmentService()
    }
    
    func makeGradebookService() -> GradebookService {
        return GradebookService()
    }
    
    func makeAnalyticsService() -> AnalyticsService {
        return AnalyticsService()
    }
    
    func makeCurriculumService() -> CurriculumService {
        return CurriculumService()
    }
    
    // Utility services
    func makeNotificationService() -> NotificationService {
        return NotificationService()
    }
    
    func makeExportService() -> ExportService {
        return ExportService()
    }
    
    func makeLogService() -> LogService {
        return LogService()
    }
}

// Mock service factory for testing and previews
class MockServiceFactory: ServiceFactory {
    // Singleton pattern
    static let shared = MockServiceFactory()
    
    private init() {}
    
    // Authentication service
    func makeAuthenticationService() -> AuthenticationService {
        let service = AuthenticationService()
        service.useTestMode = true
        return service
    }
    
    // Data services
    func makeClassService() -> ClassService {
        let service = ClassService()
        service.useTestMode = true
        return service
    }
    
    func makeStudentService() -> StudentService {
        let service = StudentService()
        service.useTestMode = true
        return service
    }
    
    func makeAssignmentService() -> AssignmentService {
        let service = AssignmentService()
        service.useTestMode = true
        return service
    }
    
    func makeGradebookService() -> GradebookService {
        return GradebookService()
    }
    
    func makeAnalyticsService() -> AnalyticsService {
        let service = AnalyticsService()
        service.useTestMode = true
        return service
    }
    
    func makeCurriculumService() -> CurriculumService {
        return CurriculumService()
    }
    
    // Utility services
    func makeNotificationService() -> NotificationService {
        let service = NotificationService()
        service.useTestMode = true
        return service
    }
    
    func makeExportService() -> ExportService {
        return ExportService()
    }
    
    func makeLogService() -> LogService {
        let service = LogService()
        service.useTestMode = true
        return service
    }
}

// Factory provider
class ServiceFactoryProvider {
    static var factory: ServiceFactory {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return MockServiceFactory.shared
        }
        #endif
        
        return ProductionServiceFactory.shared
    }
}

// Service protocols (these would be implemented by the actual service classes)

protocol AssignmentService: ObservableObject {
    var useTestMode: Bool { get set }
    var assignments: [Assignment] { get }
    func createAssignment(_ assignment: Assignment)
    func updateAssignment(_ assignment: Assignment)
    func deleteAssignment(id: String)
    func getAssignment(id: String) -> Assignment?
    func getAssignmentsForClass(classId: String) -> [Assignment]
    func getAssignmentsForStudent(studentId: String) -> [Assignment]
}

protocol GradebookService {
    func calculateGrade(for studentId: String, in classId: String) -> Double
    func getGradebookData(for classId: String) -> [GradebookData]
    func updateGrade(_ grade: Grade)
}

protocol CurriculumService {
    func getCurriculumUnits(for subject: String, gradeLevel: String) -> [CurriculumUnit]
    func getLearningObjectives(for subject: String, gradeLevel: String) -> [LearningObjective]
}

protocol NotificationService: ObservableObject {
    var useTestMode: Bool { get set }
    var notifications: [AppNotification] { get }
    func sendNotification(to userId: String, title: String, message: String, type: NotificationType)
    func markAsRead(notificationId: String)
    func clearAllNotifications(for userId: String)
}

protocol ExportService {
    func exportData(type: ExportDataType, format: ExportFormat, data: Any) -> URL?
    func exportReport(report: ReportType, data: Any, format: ExportFormat) -> URL?
}

protocol LogService {
    var useTestMode: Bool { get set }
    func logEvent(_ event: String, details: [String: Any])
    func logError(_ error: Error, details: [String: Any]?)
    func getLogs(startDate: Date, endDate: Date) -> [LogEntry]
}

// Additional types used by services
enum ExportDataType {
    case grades
    case attendance
    case analytics
    case curriculum
}

enum ReportType {
    case studentProgress
    case classPerformance
    case gradeDistribution
    case attendanceSummary
    case standardsMastery
}

struct GradebookData {
    let studentId: String
    let studentName: String
    let assignmentScores: [String: Double] // Assignment ID to score
    let overallGrade: Double
}

struct LogEntry {
    let timestamp: Date
    let eventType: String
    let userId: String?
    let details: [String: Any]
}

enum NotificationType: String {
    case newAssignment = "New Assignment"
    case gradePosted = "Grade Posted"
    case dueDate = "Due Date Reminder"
    case feedback = "Feedback Received"
    case system = "System Notification"
}

struct AppNotification: Identifiable {
    let id: String
    let userId: String
    let title: String
    let message: String
    let type: NotificationType
    let timestamp: Date
    let isRead: Bool
}