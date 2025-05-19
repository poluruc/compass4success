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
            VStack {
                // Custom header with cancel button
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    Text("Select Teacher")
                        .font(.headline)
                    
                    Spacer()
                    
                    // Balance the layout
                    Button("") {
                        // Empty action
                    }
                    .opacity(0)
                    .padding(.trailing)
                }
                .padding(.vertical, 8)
                
                // Main content
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
                        #if os(macOS)
                        // Use our fallback on macOS 13 since ContentUnavailableView is macOS 14+
                        // Fallback for macOS 13
                        VStack(spacing: 16) {
                            Image(systemName: "person.slash")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            
                            Text("No Teachers Found")
                                .font(.headline)
                            
                            Text("There are no teachers in the system yet.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        #elseif os(iOS)
                        // ContentUnavailableView on iOS is available from iOS 17+
                        // Always use fallback on iOS 16
                        VStack(spacing: 16) {
                            Image(systemName: "person.slash")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            
                            Text("No Teachers Found")
                                .font(.headline)
                            
                            Text("There are no teachers in the system yet.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        #else
                        // For any other platform, use the same fallback
                        VStack(spacing: 16) {
                            Image(systemName: "person.slash")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            
                            Text("No Teachers Found")
                                .font(.headline)
                            
                            Text("There are no teachers in the system yet.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        #endif
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
                                            
                                            Text("Subjects: \(teacher.subjects.joined(separator: ", "))")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
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
            }
            // No toolbar used anymore
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
                let subjects = teacher.subjects.joined(separator: " ").lowercased()
                return fullName.contains(lowercasedQuery) || 
                       subjects.contains(lowercasedQuery)
            }
        }
    }
    
    private func loadTeachers() {
        isLoading = true
        error = nil
        
        // In a real app, you would use a service to fetch data
        // This is mock data for demonstration
        let mockTeachers = [
            Teacher(id: "T1", firstName: "John", lastName: "Smith", subjects: ["Math", "Science"], classes: []),
            Teacher(id: "T2", firstName: "Sarah", lastName: "Johnson", subjects: ["English", "History"], classes: []),
            Teacher(id: "T3", firstName: "Michael", lastName: "Davis", subjects: ["Science", "Biology"], classes: []),
            Teacher(id: "T4", firstName: "Emily", lastName: "Wilson", subjects: ["Art", "Music"], classes: []),
            Teacher(id: "T5", firstName: "Robert", lastName: "Brown", subjects: ["Physical Education"], classes: []),
            Teacher(id: "T6", firstName: "Jennifer", lastName: "Miller", subjects: ["Chemistry", "Physics"], classes: []),
            Teacher(id: "T7", firstName: "William", lastName: "Taylor", subjects: ["Computer Science"], classes: []),
            Teacher(id: "T8", firstName: "Elizabeth", lastName: "Anderson", subjects: ["Mathematics"], classes: [])
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
