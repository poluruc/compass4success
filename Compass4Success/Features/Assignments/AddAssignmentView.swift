import SwiftUI
import Combine

struct AddAssignmentView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var classService: ClassService
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date().addingTimeInterval(60 * 60 * 24 * 7) // one week from now
    @State private var assignedDate = Date()
    @State private var totalPoints = 100
    @State private var selectedCategory = AssignmentCategory.assignment
    @State private var selectedClass: SchoolClass?
    @State private var showingClassPicker = false
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var showingCurriculumPicker = false
    @State private var selectedStandards: [String] = []
    
    var onSave: (Assignment) -> Void
    
    var formIsValid: Bool {
        !title.isEmpty && selectedClass != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Assignment Details")) {
                    TextField("Title", text: $title)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(AssignmentCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                }
                
                Section(header: Text("Schedule")) {
                    DatePicker("Assigned Date", selection: $assignedDate, displayedComponents: .date)
                    DatePicker("Due Date", selection: $dueDate, in: assignedDate..., displayedComponents: .date)
                }
                
                Section(header: Text("Class")) {
                    if let selectedClass = selectedClass {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(selectedClass.name)
                                    .font(.headline)
                                Text(selectedClass.courseCode)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showingClassPicker = true
                            }) {
                                Text("Change")
                            }
                        }
                    } else {
                        Button(action: {
                            showingClassPicker = true
                        }) {
                            Text("Select a Class")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("Grading")) {
                    Stepper("Total Points: \(totalPoints)", value: $totalPoints, in: 1...1000)
                }
                
                Section(header: Text("Curriculum Standards")) {
                    if selectedStandards.isEmpty {
                        Button(action: {
                            showingCurriculumPicker = true
                        }) {
                            Text("Add Standards")
                                .foregroundColor(.blue)
                        }
                    } else {
                        ForEach(selectedStandards, id: \.self) { standard in
                            Text(standard)
                                .font(.subheadline)
                        }
                        .onDelete(perform: deleteStandard)
                        
                        Button(action: {
                            showingCurriculumPicker = true
                        }) {
                            Text("Edit Standards")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("New Assignment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSubmitting)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAssignment()
                    }
                    .disabled(!formIsValid || isSubmitting)
                }
            }
            .sheet(isPresented: $showingClassPicker) {
                ClassPickerView { selectedClass in
                    self.selectedClass = selectedClass
                }
            }
            .sheet(isPresented: $showingCurriculumPicker) {
                CurriculumView()
                    .onDisappear {
                        // This would be replaced with actual selected standards
                        self.selectedStandards = ["MATH.K-12.1", "MATH.K-12.4", "MATH.K-12.7"]
                    }
            }
            .overlay {
                if isSubmitting {
                    ProgressView("Saving...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .shadow(radius: 10)
                }
            }
        }
    }
    
    private func deleteStandard(at offsets: IndexSet) {
        selectedStandards.remove(atOffsets: offsets)
    }
    
    private func saveAssignment() {
        guard let selectedClass = selectedClass else { return }
        
        isSubmitting = true
        errorMessage = nil
        
        // Create the new assignment
        let newAssignment = Assignment()
        newAssignment.id = UUID().uuidString
        newAssignment.title = title
        newAssignment.assignmentDescription = description
        newAssignment.dueDate = dueDate
        newAssignment.assignedDate = assignedDate
        newAssignment.category = selectedCategory.rawValue
        newAssignment.totalPoints = totalPoints
        newAssignment.classId = selectedClass.id
        newAssignment.isActive = true
        
        // In a real app, you would save to a backend service
        // Here we'll simulate a network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isSubmitting = false
            
            // Call the completion handler with the new assignment
            onSave(newAssignment)
            dismiss()
            
            // Or simulate an error (uncomment to test)
            // errorMessage = "Failed to save assignment. Please try again."
        }
    }
}

struct ClassPickerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var classService: ClassService
    @State private var classes: [SchoolClass] = []
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var onClassSelected: (SchoolClass) -> Void
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    VStack {
                        Text("Error")
                            .font(.headline)
                        Text(errorMessage)
                            .foregroundColor(.secondary)
                        
                        Button("Try Again") {
                            loadClasses()
                        }
                        .padding(.top)
                    }
                } else if classes.isEmpty {
                    ContentUnavailableView(
                        "No Classes Found",
                        systemImage: "book.closed",
                        description: Text("No classes are available.")
                    )
                } else {
                    List {
                        ForEach(filteredClasses) { schoolClass in
                            Button {
                                onClassSelected(schoolClass)
                                dismiss()
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(schoolClass.name)
                                            .font(.headline)
                                        
                                        Text("\(schoolClass.courseCode) • Grade \(schoolClass.gradeLevel)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search classes")
                }
            }
            .navigationTitle("Select Class")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadClasses()
        }
    }
    
    private var filteredClasses: [SchoolClass] {
        if searchText.isEmpty {
            return classes
        } else {
            let lowercasedQuery = searchText.lowercased()
            return classes.filter {
                $0.name.lowercased().contains(lowercasedQuery) ||
                $0.courseCode.lowercased().contains(lowercasedQuery)
            }
        }
    }
    
    private func loadClasses() {
        isLoading = true
        errorMessage = nil
        
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
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.classes = mockClasses
            self.isLoading = false
        }
    }
}

// Preview provider
struct AddAssignmentView_Previews: PreviewProvider {
    static var previews: some View {
        AddAssignmentView { _ in
            // Do nothing in preview
        }
        .environmentObject(ClassService())
    }
}