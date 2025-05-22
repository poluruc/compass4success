import Foundation
import SwiftUI

class AssignmentViewModel: ObservableObject {
    @Published var assignment: Assignment
    @Published var submissions: [Submission]
    @Published var students: [String: Student] = [:]
    @Published var courseGrades: [String: Double] = [:]
    @Published var selectedScoringMethod: ScoringMethod = .direct
    @Published var showingGradeHistory = false
    @Published var gradeHistory: [GradeHistoryEntry] = []
    
    init(assignment: Assignment) {
        self.assignment = assignment
        self.submissions = Array(assignment.submissions)
        // Set initial scoring method based on whether assignment has a rubric
        self.selectedScoringMethod = assignment.rubricId != nil ? .rubric : .direct
    }
    
    func updateSubmission(_ updated: Submission) {
        if let idx = submissions.firstIndex(where: { $0.id == updated.id }) {
            submissions[idx] = updated
            // Also update in the assignment object if needed
            if let aidx = assignment.submissions.firstIndex(where: { $0.id == updated.id }) {
                assignment.submissions[aidx] = updated
            }
        }
    }
    
    func loadStudentInfo(studentId: String) {
        // In a real app, this would fetch from a database
        // For now, create a mock student with proper names
        let student = Student()
        student.id = studentId
        
        // Use proper names instead of generic "Student" names
        let firstNames = ["Emma", "Liam", "Olivia", "Noah", "Sophia", "Jackson", "Ava", "Lucas", "Isabella", "Ethan"]
        let lastNames = ["Johnson", "Smith", "Davis", "Wilson", "Martinez", "Brown", "Garcia", "Rodriguez", "Lopez", "Lee"]
        
        // Use consistent naming based on the student ID to ensure the same student always has the same name
        let nameIndex = abs(studentId.hashValue) % firstNames.count
        student.firstName = firstNames[nameIndex]
        student.lastName = lastNames[(nameIndex + 2) % lastNames.count]
        
        student.studentNumber = "\(Int.random(in: 10000...99999))"
        student.grade = "\(Int.random(in: 9...12))"
        
        // Generate a random course grade
        let courseGrade = Double.random(in: 65...95)
        
        DispatchQueue.main.async {
            self.students[studentId] = student
            self.courseGrades[studentId] = courseGrade
        }
    }
    
    func getStudentCourseGrade(_ student: Student) -> Double? {
        return courseGrades[student.id]
    }
    
    func updateSubmissionGrade(submission: Submission, score: Int, feedback: String, completion: @escaping (Bool) -> Void) {
        // In a real app, this would update the database
        // For the mock, update the local object
        if let index = submissions.firstIndex(where: { $0.id == submission.id }) {
            submissions[index].score = score
            submissions[index].comments = feedback
            submissions[index].statusEnum = .graded
            
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion(true)
            }
        } else {
            completion(false)
        }
    }
    
    func updateSubmissionStatus(submission: Submission, status: CoreSubmissionStatus, completion: @escaping (Bool) -> Void) {
        // In a real app, this would update the database
        if let index = submissions.firstIndex(where: { $0.id == submission.id }) {
            submissions[index].statusEnum = status
            
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion(true)
            }
        } else {
            completion(false)
        }
    }
    
    func loadGradeHistory(for submission: Submission) {
        // In a real app, this would fetch from a database
        // For now, create mock history
        gradeHistory = [
            GradeHistoryEntry(date: Date().addingTimeInterval(-86400), score: 85, feedback: "First submission"),
            GradeHistoryEntry(date: Date().addingTimeInterval(-43200), score: 90, feedback: "Resubmission with improvements")
        ]
    }
} 