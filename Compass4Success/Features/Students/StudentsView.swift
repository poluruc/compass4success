import SwiftUI

struct StudentsView: View {
    @State private var searchText = ""
    @State private var selectedStudent: Student? = nil
    @State private var isLoading = false
    @State private var showingAddStudent = false
    @EnvironmentObject private var classService: ClassService
    
    // Simplified for demo - in a real app, this would be from a student service
    private var allStudents: [Student] {
        var students: [Student] = []
        for schoolClass in classService.classes {
            for student in schoolClass.students {
                if !students.contains(where: { $0.id == student.id }) {
                    students.append(student)
                }
            }
        }
        return students
    }
    
    var filteredStudents: [Student] {
        if searchText.isEmpty {
            return allStudents
        } else {
            return allStudents.filter { student in
                student.fullName.lowercased().contains(searchText.lowercased()) ||
                student.email.lowercased().contains(searchText.lowercased()) ||
                student.studentNumber.contains(searchText)
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                // Search bar
                SearchBar(text: $searchText, placeholder: "Search students...")
                    .padding(.horizontal)
                
                if filteredStudents.isEmpty {
                    EmptyStateView(
                        icon: "person.slash",
                        title: "No Students Found",
                        message: searchText.isEmpty ? 
                            "Add your first student to get started." : 
                            "No students match your search criteria.",
                        buttonText: "Add Student",
                        action: { showingAddStudent = true }
                    )
                } else {
                    // Student list
                    ScrollView {
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
            StudentDetailView(student: student) { _ in
                // Handle student update completion here if needed
            }
            #if os(iOS)
            .presentationDetents([.medium, .large])
            #endif
        }
        .onAppear {
            loadData()
        }
    }
    
    private func loadData() {
        isLoading = true
        // In a real app, this would call a service to load student data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
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
                    
                    Text(student.letterGrade)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(getColorForGrade(avgGrade))
                } else {
                    Text("N/A")
                        .font(.headline)
                        .foregroundColor(.gray)
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
