import Foundation
import Combine
import SwiftUI
import RealmSwift

class StudentsViewModel: ObservableObject {
    @Published var students: [Student] = []
    @Published var filteredStudents: [Student] = []
    @Published var selectedClass: SchoolClass?
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var sortOption: SortOption = .nameAsc
    @Published var filterGrade: String? = nil
    @Published var error: Error?
    
    // Statistics
    @Published var totalStudents = 0
    @Published var averageGrade = 0.0
    @Published var gradeDistribution: [String: Int] = [:]
    @Published var genderDistribution: [String: Int] = [:]
    
    enum SortOption: String, CaseIterable, Identifiable {
        case nameAsc = "Name (A-Z)"
        case nameDesc = "Name (Z-A)"
        case gradeAsc = "Grade (Low-High)"
        case gradeDesc = "Grade (High-Low)"
        case idAsc = "ID (Ascending)"
        case idDesc = "ID (Descending)"
        
        var id: String { self.rawValue }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let studentService = StudentService()
    
    init() {
        // Setup observers for filtering and sorting
        Publishers.CombineLatest3($searchText, $sortOption, $filterGrade)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] (_, _, _) in
                self?.filterAndSortStudents()
            }
            .store(in: &cancellables)
    }
    
    func loadStudents(forClass classId: String? = nil) {
        isLoading = true
        error = nil
        
        // In a real app, you would call a service to fetch the data
        // Here we'll create mock data
        
        var mockStudents = [
            createMockStudent(id: "1", firstName: "Emma", lastName: "Johnson", grade: "9", gender: "Female", gpa: 3.9),
            createMockStudent(id: "2", firstName: "Noah", lastName: "Williams", grade: "9", gender: "Male", gpa: 3.5),
            createMockStudent(id: "3", firstName: "Olivia", lastName: "Brown", grade: "9", gender: "Female", gpa: 4.0),
            createMockStudent(id: "4", firstName: "Liam", lastName: "Jones", grade: "9", gender: "Male", gpa: 3.2),
            createMockStudent(id: "5", firstName: "Ava", lastName: "Garcia", grade: "10", gender: "Female", gpa: 3.8),
            createMockStudent(id: "6", firstName: "Ethan", lastName: "Miller", grade: "10", gender: "Male", gpa: 2.9),
            createMockStudent(id: "7", firstName: "Sophia", lastName: "Davis", grade: "10", gender: "Female", gpa: 3.7),
            createMockStudent(id: "8", firstName: "Mason", lastName: "Rodriguez", grade: "10", gender: "Male", gpa: 3.1),
            createMockStudent(id: "9", firstName: "Isabella", lastName: "Wilson", grade: "11", gender: "Female", gpa: 3.6),
            createMockStudent(id: "10", firstName: "Jacob", lastName: "Anderson", grade: "11", gender: "Male", gpa: 3.3),
            createMockStudent(id: "11", firstName: "Mia", lastName: "Thomas", grade: "11", gender: "Female", gpa: 3.9),
            createMockStudent(id: "12", firstName: "William", lastName: "Taylor", grade: "11", gender: "Male", gpa: 2.8),
            createMockStudent(id: "13", firstName: "Charlotte", lastName: "Moore", grade: "12", gender: "Female", gpa: 4.0),
            createMockStudent(id: "14", firstName: "James", lastName: "Martin", grade: "12", gender: "Male", gpa: 3.6),
            createMockStudent(id: "15", firstName: "Amelia", lastName: "Jackson", grade: "12", gender: "Female", gpa: 3.5),
            createMockStudent(id: "16", firstName: "Benjamin", lastName: "White", grade: "12", gender: "Male", gpa: 3.2)
        ]
        
        // Add class enrollments to each student
        for student in mockStudents {
            // Add 2-4 random classes for each student
            let classCount = Int.random(in: 2...4)
            let classList = ["1", "2", "3", "4", "5", "6", "7", "8"]
            let selectedClasses = classList.shuffled().prefix(classCount)
            
            for classId in selectedClasses {
                let enrollment = StudentClassEnrollment()
                enrollment.classId = classId
                enrollment.studentId = student.id
                enrollment.enrollmentDate = Date()
                student.enrollments.append(enrollment)
                
                // Create a corresponding class with a grade
                let schoolClass = SchoolClass()
                schoolClass.id = UUID().uuidString
                schoolClass.name = getClassNameForId(classId)
                schoolClass.finalGrade = Double.random(in: 70...100).rounded()
                student.courses.append(schoolClass)
            }
        }
        
        // If a class ID is provided, filter the students to only those enrolled in that class
        if let classId = classId {
            mockStudents = mockStudents.filter { student in
                student.enrollments.contains { $0.classId == classId }
            }
        }
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.students = mockStudents
            self.calculateStatistics()
            self.filterAndSortStudents()
            self.isLoading = false
        }
    }
    
    func addStudent(_ student: Student) {
        students.append(student)
        calculateStatistics()
        filterAndSortStudents()
    }
    
    func updateStudent(_ student: Student) {
        if let index = students.firstIndex(where: { $0.id == student.id }) {
            students[index] = student
            calculateStatistics()
            filterAndSortStudents()
        }
    }
    
    func deleteStudent(_ student: Student) {
        students.removeAll { $0.id == student.id }
        calculateStatistics()
        filterAndSortStudents()
    }
    
    func reloadData() {
        loadStudents(forClass: selectedClass?.id)
    }
    
    // MARK: - Private Methods
    
    private func filterAndSortStudents() {
        var result = students
        
        // Apply text search filter
        if !searchText.isEmpty {
            let lowercasedQuery = searchText.lowercased()
            result = result.filter { student in
                student.firstName.lowercased().contains(lowercasedQuery) ||
                student.lastName.lowercased().contains(lowercasedQuery) ||
                student.email.lowercased().contains(lowercasedQuery) ||
                student.studentNumber.lowercased().contains(lowercasedQuery)
            }
        }
        
        // Apply grade filter
        if let filterGrade = filterGrade {
            result = result.filter { $0.grade == filterGrade }
        }
        
        // Apply sorting
        switch sortOption {
        case .nameAsc:
            result.sort { s1, s2 in 
                return (s1.lastName + s1.firstName) < (s2.lastName + s2.firstName)
            }
        case .nameDesc:
            result.sort { s1, s2 in
                return (s1.lastName + s1.firstName) > (s2.lastName + s2.firstName)
            }
        case .gradeAsc:
            result.sort { s1, s2 in
                return s1.gpa < s2.gpa
            }
        case .gradeDesc:
            result.sort { s1, s2 in
                return s1.gpa > s2.gpa
            }
        case .idAsc:
            result.sort { s1, s2 in
                return s1.studentNumber < s2.studentNumber
            }
        case .idDesc:
            result.sort { s1, s2 in
                return s1.studentNumber > s2.studentNumber
            }
        }
        
        filteredStudents = result
    }
    
    private func calculateStatistics() {
        totalStudents = students.count
        
        // Calculate average GPA
        if !students.isEmpty {
            let totalGpa = students.reduce(0.0) { sum, student in
                return sum + student.gpa
            }
            averageGrade = totalGpa / Double(students.count)
        } else {
            averageGrade = 0
        }
        
        // Calculate grade distribution
        var gradeCounts: [String: Int] = [:]
        for student in students {
            gradeCounts[student.grade, default: 0] += 1
        }
        gradeDistribution = gradeCounts
        
        // Calculate gender distribution
        var genderCounts: [String: Int] = [:]
        for student in students {
            genderCounts[student.gender, default: 0] += 1
        }
        genderDistribution = genderCounts
    }
    
    private func getClassNameForId(_ classId: String) -> String {
        // This would come from a real class service
        let classNames = [
            "1": "Algebra I",
            "2": "Biology",
            "3": "World History",
            "4": "English Literature",
            "5": "Physical Science",
            "6": "Geometry",
            "7": "Computer Science",
            "8": "Art History"
        ]
        
        return classNames[classId] ?? "Unknown Class"
    }
    
    private func createMockStudent(id: String, firstName: String, lastName: String, grade: String, gender: String, gpa: Double) -> Student {
        let student = Student()
        student.id = id
        student.firstName = firstName
        student.lastName = lastName
        student.grade = grade
        student.email = "\(firstName.lowercased()).\(lastName.lowercased())@school.edu"
        student.studentNumber = String(format: "S%05d", Int.random(in: 10000...99999))
        student.gender = gender
        // Can't directly set gpa since it's a computed property
        // We'll need to set average grade in a different way if needed
        return student
    }
}

// Extensions for the Student model
// Mock Course class until real one is developed
class Course: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var name: String = ""
    @Persisted var finalGrade: Double?
}