import Foundation
import Combine

class StudentService: ObservableObject {
    @Published var students: [Student] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Initialize the service
    }
    
    func loadStudents(forClass classId: String? = nil, completion: @escaping ([Student]) -> Void) {
        isLoading = true
        error = nil
        
        // Simulate network request with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let mockStudents = self.generateMockStudents(forClass: classId)
            self.students = mockStudents
            self.isLoading = false
            completion(mockStudents)
        }
    }
    
    func createStudent(_ student: Student, completion: @escaping (Result<Student, Error>) -> Void) {
        isLoading = true
        error = nil
        
        // Simulate network request with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.students.append(student)
            self.isLoading = false
            completion(.success(student))
        }
    }
    
    func updateStudent(_ student: Student, completion: @escaping (Result<Student, Error>) -> Void) {
        isLoading = true
        error = nil
        
        // Simulate network request with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let index = self.students.firstIndex(where: { $0.id == student.id }) {
                self.students[index] = student
                self.isLoading = false
                completion(.success(student))
            } else {
                self.isLoading = false
                let error = NSError(domain: "StudentService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Student not found"])
                self.error = error
                completion(.failure(error))
            }
        }
    }
    
    func deleteStudent(_ student: Student, completion: @escaping (Result<Void, Error>) -> Void) {
        isLoading = true
        error = nil
        
        // Simulate network request with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.students.removeAll { $0.id == student.id }
            self.isLoading = false
            completion(.success(()))
        }
    }
    
    // MARK: - Private Methods
    
    private func generateMockStudents(forClass classId: String? = nil) -> [Student] {
        var mockStudents = [
            createMockStudent(id: "1", firstName: "Emma", lastName: "Johnson", grade: "9"),
            createMockStudent(id: "2", firstName: "Noah", lastName: "Williams", grade: "9"),
            createMockStudent(id: "3", firstName: "Olivia", lastName: "Brown", grade: "9"),
            createMockStudent(id: "4", firstName: "Liam", lastName: "Jones", grade: "9"),
            createMockStudent(id: "5", firstName: "Ava", lastName: "Garcia", grade: "10"),
            createMockStudent(id: "6", firstName: "Ethan", lastName: "Miller", grade: "10"),
            createMockStudent(id: "7", firstName: "Sophia", lastName: "Davis", grade: "10"),
            createMockStudent(id: "8", firstName: "Mason", lastName: "Rodriguez", grade: "10")
        ]
        
        // If a class ID is provided, filter students
        if let classId = classId {
            // In a real app, this would query the database
            // Here we'll just return a subset of the mock data
            mockStudents = mockStudents.filter { _ in Bool.random() }
        }
        
        return mockStudents
    }
    
    private func createMockStudent(id: String, firstName: String, lastName: String, grade: String) -> Student {
        let student = Student()
        student.id = id
        student.firstName = firstName
        student.lastName = lastName
        student.grade = grade
        student.email = "\(firstName.lowercased()).\(lastName.lowercased())@school.edu"
        student.studentNumber = String(format: "S%05d", Int.random(in: 10000...99999))
        student.gender = ["Male", "Female"].randomElement() ?? "Male"
        return student
    }
}
