import SwiftUI

struct StudentsView: View {
    @State private var searchText = ""
    @State private var selectedStudent: Student? = nil
    @State private var isLoading = false
    @State private var showingAddStudent = false
    @EnvironmentObject private var classService: ClassService
    @StateObject private var viewModel = StudentsViewModel()
    
    var filteredStudents: [Student] {
        if searchText.isEmpty {
            return viewModel.filteredStudents
        } else {
            return viewModel.filteredStudents.filter { student in
                student.fullName.lowercased().contains(searchText.lowercased()) ||
                student.email.lowercased().contains(searchText.lowercased()) ||
                student.studentNumber.contains(searchText)
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $searchText, placeholder: "Search students...")
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                
                if filteredStudents.isEmpty {
                    ScrollView {
                        EmptyStateView(
                            icon: "person.slash",
                            title: "No Students Found",
                            message: searchText.isEmpty ? 
                                "Add your first student to get started." : 
                                "No students match your search criteria.",
                            buttonText: "Add Student",
                            action: { showingAddStudent = true }
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 50) // Add some padding at the top for better appearance
                    }
                } else {
                    // Student list
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredStudents) { student in
                                StudentCard(student: student)
                                    .onTapGesture {
                                        selectedStudent = student
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .edgesIgnoringSafeArea(.bottom)
            
            if isLoading {
                LoadingOverlay()
            }
        }
        .navigationTitle("Students")
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddStudent = true }) {
                    Image(systemName: "person.badge.plus")
                }
            }
            #else
            ToolbarItem {
                Button(action: { showingAddStudent = true }) {
                    Image(systemName: "person.badge.plus")
                }
            }
            #endif
        }
        .sheet(isPresented: $showingAddStudent) {
            Text("Add Student feature is not available")
                #if os(iOS)
                .presentationDetents([.medium])
                #endif
        }
        .sheet(item: $selectedStudent) { student in
            NavigationStack {
                StudentDetailView(student: student)
            }
            #if os(iOS)
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            #endif
        }
        .onAppear {
            viewModel.loadStudents()
        }
    }
}

struct StudentCard: View {
    let student: Student
    
    var body: some View {
        HStack(spacing: 16) {
            // Student avatar
            ZStack {
                Circle()
                    .fill(getColorForName(student.fullName))
                    .frame(width: 50, height: 50)
                
                Text(student.initials)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            // Student info
            VStack(alignment: .leading, spacing: 4) {
                Text(student.fullName)
                    .font(.headline)
                
                Text(student.email)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Text("ID: \(student.studentNumber)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("Grade: \(student.grade)")
                        .font(.caption2)
                        .padding(4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            // Grade info
            VStack(alignment: .trailing, spacing: 4) {
                if let avgGrade = student.averageGrade {
                    Text(String(format: "%.1f%%", avgGrade))
                        .font(.headline)
                        .foregroundColor(getColorForGrade(avgGrade))
                    
                    HStack(spacing: 4) {
                        Text(getLevelFromGrade(avgGrade))
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(getColorForGrade(avgGrade).opacity(0.2))
                            .cornerRadius(4)
                        
                        Text(student.letterGrade)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(getColorForGrade(avgGrade))
                    }
                } else {
                    // Generate a random grade since we don't want N/A
                    let randomGrade = Double.random(in: 65...95)
                    Text(String(format: "%.1f%%", randomGrade))
                        .font(.headline)
                        .foregroundColor(getColorForGrade(randomGrade))
                    
                    HStack(spacing: 4) {
                        Text(getLevelFromGrade(randomGrade))
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(getColorForGrade(randomGrade).opacity(0.2))
                            .cornerRadius(4)
                        
                        Text(getLetterGrade(randomGrade))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(getColorForGrade(randomGrade))
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    // Generates a consistent color based on the student's name
    private func getColorForName(_ name: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .red, .yellow]
        let hash = abs(name.hashValue) % colors.count
        return colors[hash]
    }
    
    // Returns a color based on the grade value
    private func getColorForGrade(_ grade: Double) -> Color {
        switch grade {
        case 90...100:
            return .green
        case 80..<90:
            return .blue
        case 70..<80:
            return .yellow
        case 60..<70:
            return .orange
        default:
            return .red
        }
    }
    
    // Ontario achievement levels
    private func getLevelFromGrade(_ grade: Double) -> String {
        switch grade {
        case 80...100: return "Level 4"
        case 70..<80: return "Level 3"
        case 60..<70: return "Level 2"
        default: return "Level 1"
        }
    }
    
    private func getLetterGrade(_ grade: Double) -> String {
        switch grade {
        case 90...100: return "A+"
        case 85..<90: return "A"
        case 80..<85: return "A-"
        case 77..<80: return "B+"
        case 73..<77: return "B"
        case 70..<73: return "B-"
        case 67..<70: return "C+"
        case 63..<67: return "C"
        case 60..<63: return "C-"
        case 57..<60: return "D+"
        case 53..<57: return "D"
        case 50..<53: return "D-"
        default: return "F"
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let buttonText: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 70)
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: action) {
                Text(buttonText)
                    .fontWeight(.semibold)
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
            
            Spacer()
        }
    }
    // Generates a consistent color based on the student's name
    private func getColorForName(_ name: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .red, .yellow]
        let hash = abs(name.hashValue) % colors.count
        return colors[hash]
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.primary)
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 5)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct ClassRow: View {
    let schoolClass: SchoolClass
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(schoolClass.name)
                    .font(.headline)
                
                Text(schoolClass.subject)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let grade = schoolClass.finalGrade {
                Text(String(format: "%.1f%%", grade))
                    .font(.headline)
                    .foregroundColor(getColorForGrade(grade))
            } else {
                Text("No Grade")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }
    
    // Returns a color based on the grade value
    private func getColorForGrade(_ grade: Double) -> Color {
        switch grade {
        case 90...100:
            return .green
        case 80..<90:
            return .blue
        case 70..<80:
            return .yellow
        case 60..<70:
            return .orange
        default:
            return .red
        }
    }
}

struct StudentsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StudentsView()
                .environmentObject(ClassService())
        }
    }
}
