import Foundation
import Combine
import SwiftUI

class AssignmentsViewModel: ObservableObject {
    @Published var assignments: [Assignment] = []
    @Published var filteredAssignments: [Assignment] = []
    @Published var selectedClass: SchoolClass?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var filterOption: FilterOption = .all
    @Published var sortOption: SortOption = .dueDate
    
    enum FilterOption: String, CaseIterable, Identifiable {
        case all = "All"
        case active = "Active"
        case pastDue = "Past Due"
        case upcoming = "Upcoming (7 Days)"
        case completed = "Completed"
        
        var id: String { self.rawValue }
    }
    
    enum SortOption: String, CaseIterable, Identifiable {
        case dueDate = "Due Date"
        case title = "Title"
        case dateAssigned = "Date Assigned"
        case submissionCount = "Submissions"
        
        var id: String { self.rawValue }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Setup subscribers for filtering
        $searchText
            .combineLatest($filterOption, $sortOption, $assignments)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] (searchText, filterOption, sortOption, assignments) in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }
    
    func loadAssignments(for classId: String? = nil) {
        isLoading = true
        errorMessage = nil
        
        // In a real app, you'd fetch data from a service
        // Here we'll create mock data
        
        // Create a realistic date range spanning 3 weeks
        let today = Date()
        let calendar = Calendar.current
        let pastTwoWeeks = calendar.date(byAdding: .day, value: -14, to: today)!
        let nextTwoWeeks = calendar.date(byAdding: .day, value: 14, to: today)!
        
        let mockAssignments = [
            createAssignment(
                id: "1",
                title: "Math Quiz",
                description: "Chapter 5 Quiz covering logarithmic functions",
                dueDate: calendar.date(byAdding: .day, value: 1, to: today)!,
                assignedDate: pastTwoWeeks,
                classId: "1",
                category: .quiz,
                isActive: true,
                submissions: 15
            ),
            createAssignment(
                id: "2",
                title: "History Essay",
                description: "1000-word essay on the Industrial Revolution",
                dueDate: calendar.date(byAdding: .day, value: 5, to: today)!,
                assignedDate: calendar.date(byAdding: .day, value: -3, to: today)!,
                classId: "3",
                category: .assignment,
                isActive: true,
                submissions: 8
            ),
            createAssignment(
                id: "3",
                title: "Science Lab Report",
                description: "Lab report on the photosynthesis experiment",
                dueDate: calendar.date(byAdding: .day, value: -2, to: today)!,
                assignedDate: calendar.date(byAdding: .day, value: -7, to: today)!,
                classId: "2",
                category: .lab,
                isActive: true,
                submissions: 22
            ),
            createAssignment(
                id: "4",
                title: "English Presentation",
                description: "Group presentation on Shakespeare's Macbeth",
                dueDate: calendar.date(byAdding: .day, value: 10, to: today)!,
                assignedDate: calendar.date(byAdding: .day, value: -1, to: today)!,
                classId: "4",
                category: .presentation,
                isActive: true,
                submissions: 0
            ),
            createAssignment(
                id: "5",
                title: "Computer Science Project",
                description: "Create a simple web application using HTML, CSS, and JavaScript",
                dueDate: calendar.date(byAdding: .day, value: 7, to: today)!,
                assignedDate: calendar.date(byAdding: .day, value: -5, to: today)!,
                classId: "7",
                category: .project,
                isActive: true,
                submissions: 5
            ),
            createAssignment(
                id: "6", 
                title: "Art History Analysis",
                description: "Analysis of Renaissance artwork styles and influences",
                dueDate: calendar.date(byAdding: .day, value: -5, to: today)!,
                assignedDate: calendar.date(byAdding: .day, value: -12, to: today)!,
                classId: "8",
                category: .assignment,
                isActive: false,
                submissions: 27
            )
        ]
        
        // Filter by class if specified
        let filtered = classId == nil ? mockAssignments : mockAssignments.filter { $0.classId == classId }
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.assignments = filtered
            self.applyFilters()
            self.isLoading = false
        }
    }
    
    func deleteAssignment(_ assignment: Assignment) {
        // In a real app, you'd call a service to delete the assignment
        print("Deleting assignment: \(assignment.title)")
        
        // Remove from local arrays
        if let index = assignments.firstIndex(where: { $0.id == assignment.id }) {
            assignments.remove(at: index)
        }
        
        if let index = filteredAssignments.firstIndex(where: { $0.id == assignment.id }) {
            filteredAssignments.remove(at: index)
        }
    }
    
    func duplicateAssignment(_ assignment: Assignment) -> Assignment {
        // Create a copy with a new ID
        let copy = createAssignment(
            id: UUID().uuidString,
            title: "Copy of \(assignment.title)",
            description: assignment.assignmentDescription,
            dueDate: assignment.dueDate,
            assignedDate: Date(),
            classId: assignment.classId,
            category: AssignmentCategory(rawValue: assignment.category) ?? .assignment,
            isActive: assignment.isActive,
            submissions: 0
        )
        
        // In a real app, you'd save this to your backend
        assignments.append(copy)
        applyFilters()
        
        return copy
    }
    
    // MARK: - Helper methods
    
    private func applyFilters() {
        var result = assignments
        
        // Apply search filter if text is not empty
        if !searchText.isEmpty {
            let lowercasedQuery = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(lowercasedQuery) ||
                $0.assignmentDescription.lowercased().contains(lowercasedQuery)
            }
        }
        
        // Apply status filter
        switch filterOption {
        case .all:
            // No additional filtering
            break
        case .active:
            result = result.filter { $0.isActive }
        case .pastDue:
            result = result.filter { $0.dueDate < Date() && $0.isActive }
        case .upcoming:
            let oneWeekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
            result = result.filter { $0.dueDate > Date() && $0.dueDate <= oneWeekFromNow && $0.isActive }
        case .completed:
            result = result.filter { !$0.isActive }
        }
        
        // Apply sorting
        switch sortOption {
        case .dueDate:
            result.sort { $0.dueDate < $1.dueDate }
        case .title:
            result.sort { $0.title < $1.title }
        case .dateAssigned:
            result.sort { $0.assignedDate < $1.assignedDate }
        case .submissionCount:
            result.sort { $0.submissions.count > $1.submissions.count }
        }
        
        filteredAssignments = result
    }
    
    private func createAssignment(
        id: String,
        title: String,
        description: String,
        dueDate: Date,
        assignedDate: Date,
        classId: String,
        category: AssignmentCategory,
        isActive: Bool,
        submissions: Int
    ) -> Assignment {
        let assignment = Assignment()
        assignment.id = id
        assignment.title = title
        assignment.assignmentDescription = description
        assignment.dueDate = dueDate
        assignment.assignedDate = assignedDate
        assignment.classId = classId
        assignment.category = category.rawValue
        assignment.isActive = isActive
        
        // Create mock submissions
        for i in 0..<submissions {
            let submission = AssignmentSubmission()
            submission.id = UUID().uuidString
            submission.studentId = "student\(i)"
            submission.submissionDate = Date().addingTimeInterval(Double(-i) * 3600)
            submission.grade = Double.random(in: 60...100)
            assignment.submissions.append(submission)
        }
        
        return assignment
    }
}