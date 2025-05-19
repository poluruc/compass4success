import SwiftUI
import Combine

struct TeacherPickerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var classService: ClassService
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var teachers: [Teacher] = []
    @State private var error: Error?
    @State private var cancellables = Set<AnyCancellable>()
    
    var onTeacherSelected: (Teacher) -> Void
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = error {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        
                        Text("Error loading teachers")
                            .font(.headline)
                        
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Retry") {
                            loadTeachers()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if teachers.isEmpty {
                    ContentUnavailableView(
                        "No Teachers Found",
                        systemImage: "person.slash",
                        description: Text("There are no teachers in the system yet.")
                    )
                } else {
                    List {
                        ForEach(filteredTeachers) { teacher in
                            Button(action: {
                                onTeacherSelected(teacher)
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.blue)
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading) {
                                        Text("\(teacher.firstName) \(teacher.lastName)")
                                            .font(.headline)
                                        
                                        if !teacher.email.isEmpty {
                                            Text(teacher.email)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search by name or email")
                }
            }
            .navigationTitle("Select Teacher")
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
            loadTeachers()
        }
    }
    
    private var filteredTeachers: [Teacher] {
        if searchText.isEmpty {
            return teachers
        } else {
            let lowercasedQuery = searchText.lowercased()
            return teachers.filter { teacher in
                let fullName = "\(teacher.firstName) \(teacher.lastName)".lowercased()
                return fullName.contains(lowercasedQuery) || 
                       teacher.email.lowercased().contains(lowercasedQuery)
            }
        }
    }
    
    private func loadTeachers() {
        isLoading = true
        error = nil
        
        // In a real app, you would use a service to fetch data
        // This is mock data for demonstration
        let mockTeachers = [
            Teacher(firstName: "John", lastName: "Smith", email: "john.smith@school.edu"),
            Teacher(firstName: "Sarah", lastName: "Johnson", email: "sjohnson@school.edu"),
            Teacher(firstName: "Michael", lastName: "Davis", email: "mdavis@school.edu"),
            Teacher(firstName: "Emily", lastName: "Wilson", email: "ewilson@school.edu"),
            Teacher(firstName: "Robert", lastName: "Brown", email: "rbrown@school.edu"),
            Teacher(firstName: "Jennifer", lastName: "Miller", email: "jmiller@school.edu"),
            Teacher(firstName: "William", lastName: "Taylor", email: "wtaylor@school.edu"),
            Teacher(firstName: "Elizabeth", lastName: "Anderson", email: "eanderson@school.edu")
        ]
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.teachers = mockTeachers
            self.isLoading = false
        }
    }
}

// For SwiftUI preview
struct TeacherPickerView_Previews: PreviewProvider {
    static var previews: some View {
        TeacherPickerView { teacher in
            print("Selected teacher: \(teacher.firstName) \(teacher.lastName)")
        }
        .environmentObject(ClassService())
    }
}