import Foundation
import Combine
import SwiftUI

class GradebookViewModelTest: ObservableObject {
    @Published var selectedClass: SchoolClass?
    @Published var students: [Student] = []
    @Published var assignments: [Assignment] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var editingMode = false
    @Published var selectedGradebookView: GradebookViewType = .assignments
    @Published var showAllStudents = false
    @Published var searchText = ""
    @Published var sortOption: SortOption = .nameAsc
    
    enum GradebookViewType: String, CaseIterable, Identifiable {
        case assignments = "Assignments"
        case standards = "Standards"
        case statistics = "Statistics"
        
        var id: String { self.rawValue }
    }
    
    enum SortOption: String, CaseIterable, Identifiable {
        case nameAsc = "Name (A-Z)"
        case nameDesc = "Name (Z-A)"
        case gradeAsc = "Grade (Low-High)"
        case gradeDesc = "Grade (High-Low)"
        
        var id: String { self.rawValue }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let classService: ClassService
    
    init(classService: ClassService) {
        self.classService = classService
        
        // Setup observers
        $selectedClass
            .sink { [weak self] schoolClass in
                if schoolClass != nil {
                    self?.loadGradebookData()
                } else {
                    self?.students = []
                    self?.assignments = []
                }
            }
            .store(in: &cancellables)
        
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.filterStudents()
            }
            .store(in: &cancellables)
        
        $sortOption
            .sink { [weak self] _ in
                self?.sortStudents()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func loadGradebookData() {
        guard let selectedClass = selectedClass else { return }
        
        isLoading = true
        error = nil
        
        // Mock students and assignments
        let mockStudents = createMockStudents()
        let mockAssignments = createMockAssignments()
        
        // Add random grades for each student and assignment
        for student in mockStudents {
            for assignment in mockAssignments {
                // 80% chance to have a grade, 20% chance to be absent/not submitted
                if Double.random(in: 0...1) <= 0.8 {
                    // Create a submission with a score between 60 and 100
                    let scoreValue = Int(Double.random(in: 60...100))
                    
                    let submission = Submission()
                    submission.id = UUID().uuidString
                    submission.studentId = student.id
                    submission.assignmentId = assignment.id
                    submission.score = scoreValue
                    submission.submittedDate = assignment.dueDate.addingTimeInterval(-Double.random(in: 0...(86400)))
                    submission.status = CoreSubmissionStatus.submitted.rawValue
                    
                    assignment.submissions.append(submission)
                }
            }
        }
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.students = mockStudents
            self.assignments = mockAssignments
            self.isLoading = false
        }
    }
    
    func updateGrade(for student: Student, assignment: Assignment, newGrade: Double?) {
        // Find the submission for this student
        if let submissionIndex = assignment.submissions.firstIndex(where: { $0.studentId == student.id }) {
            // Update existing submission
            if let newGradeValue = newGrade {
                assignment.submissions[submissionIndex].score = Int(newGradeValue)
            }
        } else if let newGrade = newGrade {
            // Create a new submission
            let submission = Submission()
            submission.id = UUID().uuidString
            submission.studentId = student.id
            submission.assignmentId = assignment.id
            submission.submittedDate = Date()
            submission.score = Int(newGrade)
            submission.status = CoreSubmissionStatus.submitted.rawValue
            
            assignment.submissions.append(submission)
        }
        
        // In a real app, you would save this to a backend service
        print("Updated grade for \(student.firstName) \(student.lastName) on \(assignment.title): \(String(describing: newGrade))")
    }
    
    func studentGrade(for student: Student, assignment: Assignment) -> Double? {
        if let submission = assignment.submissions.first(where: { $0.studentId == student.id }) {
            return Double(submission.score)
        }
        return nil
    }
    
    // Function to determine student submission status
    func studentSubmissionStatus(for student: Student, assignment: Assignment) -> GradebookTestSubmissionStatus {
        if let submission = assignment.submissions.first(where: { $0.studentId == student.id }) {
            if let status = CoreSubmissionStatus(rawValue: submission.status) {
                return convertToGradebookStatus(status)
            }
        }
        return .missing
    }
    
    // Helper to convert between submission status types
    private func convertToGradebookStatus(_ status: CoreSubmissionStatus) -> GradebookTestSubmissionStatus {
        switch status {
        case .submitted, .graded:
            return .submitted
        case .late:
            return .late
        case .notSubmitted:
            return .missing
        case .excused:
            return .excused
        default:
            return .missing
        }
    }
    
    func finalGrade(for student: Student) -> Double {
        var totalPoints = 0.0
        var earnedPoints = 0.0
        
        for assignment in assignments {
            if let submission = assignment.submissions.first(where: { $0.studentId == student.id }) {
                totalPoints += Double(assignment.totalPoints)
                // Calculate percentage of points earned
                let percentage = Double(submission.score) / 100.0
                earnedPoints += percentage * Double(assignment.totalPoints)
            }
        }
        
        return totalPoints > 0 ? (earnedPoints / totalPoints) * 100 : 0
    }
    
    // MARK: - Private Methods
    
    private func filterStudents() {
        // Implement filtering logic here
    }
    
    private func sortStudents() {
        switch sortOption {
        case .nameAsc:
            students.sort { $0.lastName + $0.firstName < $1.lastName + $1.firstName }
        case .nameDesc:
            students.sort { $0.lastName + $0.firstName > $1.lastName + $1.firstName }
        case .gradeAsc:
            students.sort { finalGrade(for: $0) < finalGrade(for: $1) }
        case .gradeDesc:
            students.sort { finalGrade(for: $0) > finalGrade(for: $1) }
        }
    }
    
    // MARK: - Mock Data Helpers
    
    private func createMockStudents() -> [Student] {
        return [
            createMockStudent(id: "1", firstName: "Emma", lastName: "Johnson", grade: "9A"),
            createMockStudent(id: "2", firstName: "Noah", lastName: "Williams", grade: "9A"),
            createMockStudent(id: "3", firstName: "Olivia", lastName: "Brown", grade: "9A"),
            createMockStudent(id: "4", firstName: "Liam", lastName: "Jones", grade: "9A"),
            createMockStudent(id: "5", firstName: "Ava", lastName: "Garcia", grade: "9A"),
            createMockStudent(id: "6", firstName: "Ethan", lastName: "Miller", grade: "9A"),
            createMockStudent(id: "7", firstName: "Sophia", lastName: "Davis", grade: "9A"),
            createMockStudent(id: "8", firstName: "Mason", lastName: "Rodriguez", grade: "9A")
        ]
    }
    
    private func createMockAssignments() -> [Assignment] {
        return [
            createMockAssignment(id: "1", title: "Math Quiz 1", date: Date().addingTimeInterval(-1209600), totalPoints: 50), // 2 weeks ago
            createMockAssignment(id: "2", title: "Math Quiz 2", date: Date().addingTimeInterval(-604800), totalPoints: 50), // 1 week ago
            createMockAssignment(id: "3", title: "Midterm Exam", date: Date().addingTimeInterval(-259200), totalPoints: 100), // 3 days ago
            createMockAssignment(id: "4", title: "Homework #5", date: Date().addingTimeInterval(-86400), totalPoints: 25) // 1 day ago
        ]
    }
    
    private func createMockStudent(id: String, firstName: String, lastName: String, grade: String) -> Student {
        let student = Student()
        student.id = id
        student.firstName = firstName
        student.lastName = lastName
        student.grade = grade
        student.email = "\(firstName.lowercased()).\(lastName.lowercased())@school.edu"
        student.studentNumber = String(format: "S%05d", Int.random(in: 10000...99999))
        return student
    }
    
    private func createMockAssignment(id: String, title: String, date: Date, totalPoints: Int) -> Assignment {
        let assignment = Assignment()
        assignment.id = id
        assignment.title = title
        assignment.assignedDate = date
        assignment.dueDate = date.addingTimeInterval(604800) // due 1 week after assigned
        assignment.totalPoints = Double(totalPoints)
        assignment.isActive = true
        return assignment
    }
}

// Submission status enum for gradebook views
enum GradebookTestSubmissionStatus: String {
    case submitted = "Submitted"
    case late = "Late"
    case missing = "Missing"
    case excused = "Excused"
    
    var color: Color {
        switch self {
        case .submitted: return .green
        case .late: return .orange
        case .missing: return .red
        case .excused: return .gray
        }
    }
} 