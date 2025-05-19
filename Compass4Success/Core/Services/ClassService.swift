import Foundation
import Combine
import SwiftUI

class ClassService: ObservableObject {
    @Published var classes: [SchoolClass] = []
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let mockService = MockDataService.shared
    
    init() {
        loadClasses()
    }
    
    func loadClasses() {
        isLoading = true
        error = nil
        
        // Use mock data from mock service
        let mockData = mockService.generateMockData()
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.classes = mockData.classes
            self.isLoading = false
        }
    }
    
    func getClass(by id: String) -> SchoolClass? {
        return classes.first { $0.id == id }
    }
    
    func createClass(_ schoolClass: SchoolClass) -> AnyPublisher<SchoolClass, Error> {
        isLoading = true
        
        return Future<SchoolClass, Error> { promise in
            // Simulate network request
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.classes.append(schoolClass)
                self.isLoading = false
                promise(.success(schoolClass))
            }
        }.eraseToAnyPublisher()
    }
    
    func updateClass(_ schoolClass: SchoolClass) -> AnyPublisher<SchoolClass, Error> {
        isLoading = true
        
        return Future<SchoolClass, Error> { promise in
            // Simulate network request
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let index = self.classes.firstIndex(where: { $0.id == schoolClass.id }) {
                    self.classes[index] = schoolClass
                    self.isLoading = false
                    promise(.success(schoolClass))
                } else {
                    self.isLoading = false
                    let error = NSError(domain: "ClassService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Class not found"])
                    self.error = error
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteClass(id: String) -> AnyPublisher<Bool, Error> {
        isLoading = true
        
        return Future<Bool, Error> { promise in
            // Simulate network request
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let index = self.classes.firstIndex(where: { $0.id == id }) {
                    self.classes.remove(at: index)
                    self.isLoading = false
                    promise(.success(true))
                } else {
                    self.isLoading = false
                    let error = NSError(domain: "ClassService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Class not found"])
                    self.error = error
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getStudentsInClass(classId: String) -> [Student] {
        if let schoolClass = getClass(by: classId) {
            return Array(schoolClass.students)
        }
        return []
    }
    
    func getAssignmentsForClass(classId: String) -> [Assignment] {
        if let schoolClass = getClass(by: classId) {
            return Array(schoolClass.assignments)
        }
        return []
    }
    
    func addStudentToClass(student: Student, classId: String) -> AnyPublisher<Bool, Error> {
        isLoading = true
        
        return Future<Bool, Error> { promise in
            // Simulate network request
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let index = self.classes.firstIndex(where: { $0.id == classId }) {
                    let studentsList = List<Student>()
                    self.classes[index].students.forEach { studentsList.append($0) }
                    studentsList.append(student)
                    self.classes[index].students = studentsList
                    
                    self.isLoading = false
                    promise(.success(true))
                } else {
                    self.isLoading = false
                    let error = NSError(domain: "ClassService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Class not found"])
                    self.error = error
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func addAssignmentToClass(assignment: Assignment, classId: String) -> AnyPublisher<Bool, Error> {
        isLoading = true
        
        return Future<Bool, Error> { promise in
            // Simulate network request
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let index = self.classes.firstIndex(where: { $0.id == classId }) {
                    let assignmentsList = List<Assignment>()
                    self.classes[index].assignments.forEach { assignmentsList.append($0) }
                    assignmentsList.append(assignment)
                    self.classes[index].assignments = assignmentsList
                    
                    self.isLoading = false
                    promise(.success(true))
                } else {
                    self.isLoading = false
                    let error = NSError(domain: "ClassService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Class not found"])
                    self.error = error
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}