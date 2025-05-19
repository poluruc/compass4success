import SwiftUI
import Combine

struct CrossClassAssignmentView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var classService: ClassService
    @State private var selectedClasses = Set<String>()
    @State private var classes: [SchoolClass] = []
    @State private var isLoading = false
    @State private var searchText = ""
    @State private var errorMessage: String?
    
    var assignment: Assignment
    var onComplete: (Result<Bool, Error>) -> Void
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if classes.isEmpty {
                    ContentUnavailableView(
                        "No Classes Available",
                        systemImage: "book.closed",
                        description: Text("There are no other classes to assign this assignment to.")
                    )
                } else {
                    List {
                        ForEach(filteredClasses) { schoolClass in
                            ClassRow(
                                schoolClass: schoolClass,
                                isSelected: selectedClasses.contains(schoolClass.id),
                                onToggle: { isSelected in
                                    if isSelected {
                                        selectedClasses.insert(schoolClass.id)
                                    } else {
                                        selectedClasses.remove(schoolClass.id)
                                    }
                                }
                            )
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search classes")
                }
            }
            .navigationTitle("Assign to Classes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Assign") {
                        assignToClasses()
                    }
                    .disabled(selectedClasses.isEmpty)
                }
            }
            .alert(
                "Error",
                isPresented: .init(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                ),
                actions: { Button("OK") {} },
                message: { Text(errorMessage ?? "") }
            )
        }
        .onAppear {
            loadClasses()
        }
    }
    
    private var filteredClasses: [SchoolClass] {
        if searchText.isEmpty {
            return classes
        } else {
            return classes.filter { schoolClass in
                schoolClass.name.localizedCaseInsensitiveContains(searchText) ||
                schoolClass.courseCode.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func loadClasses() {
        isLoading = true
        
        // In a real app, you would fetch classes from a service
        // Here we'll create mock data
        let mockClasses = [
            SchoolClass(id: "1", name: "Algebra I", courseCode: "MATH101", gradeLevel: "9"),
            SchoolClass(id: "2", name: "Biology", courseCode: "SCI101", gradeLevel: "9"),
            SchoolClass(id: "3", name: "World History", courseCode: "HIST101", gradeLevel: "9"),
            SchoolClass(id: "4", name: "English Literature", courseCode: "ENG101", gradeLevel: "9"),
            SchoolClass(id: "5", name: "Physical Science", courseCode: "SCI201", gradeLevel: "10"),
            SchoolClass(id: "6", name: "Geometry", courseCode: "MATH201", gradeLevel: "10"),
            SchoolClass(id: "7", name: "Computer Science", courseCode: "CS101", gradeLevel: "11-12"),
            SchoolClass(id: "8", name: "Art History", courseCode: "ART301", gradeLevel: "11-12")
        ]
        
        // Filter out the class that the assignment is already assigned to
        let filteredClasses = mockClasses.filter { $0.id != assignment.classId }
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.classes = filteredClasses
            self.isLoading = false
        }
    }
    
    private func assignToClasses() {
        isLoading = true
        
        // In a real app, you would save this data to a backend service
        print("Assigning assignment '\(assignment.title)' to \(selectedClasses.count) classes")
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            
            // Simulate successful assignment
            onComplete(.success(true))
            dismiss()
            
            // Or simulate an error (uncomment to test)
            // self.errorMessage = "Failed to assign to all classes. Please try again."
        }
    }
}

struct ClassRow: View {
    let schoolClass: SchoolClass
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Button(action: {
            onToggle(!isSelected)
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(schoolClass.name)
                        .font(.headline)
                    
                    Text("\(schoolClass.courseCode) • Grade \(schoolClass.gradeLevel)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// Preview provider
struct CrossClassAssignmentView_Previews: PreviewProvider {
    static var previews: some View {
        let mockAssignment = Assignment(id: "1", title: "Math Quiz", dueDate: Date().addingTimeInterval(86400), description: "Chapter 5 Quiz", submissions: [])
        mockAssignment.classId = "1"
        
        return CrossClassAssignmentView(assignment: mockAssignment) { result in
            print("Assignment complete with result: \(result)")
        }
        .environmentObject(ClassService())
    }
}