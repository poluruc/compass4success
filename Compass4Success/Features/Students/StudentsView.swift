import SwiftUI

struct StudentsView: View {
    @State private var searchText = ""
    @State private var selectedStudent: Student? = nil
    @State private var isLoading = false
    @State private var showingAddStudent = false
    @EnvironmentObject private var classService: ClassService
    @EnvironmentObject var appSettings: AppSettings
    @StateObject private var viewModel = StudentsViewModel()
    @State private var selectedClassId: String? = nil
    @State private var selectedGrade: String? = nil
    @State private var selectedSort: StudentsViewModel.SortOption = .nameAsc
    
    // Helper to get unique grades from students
    var uniqueGrades: [String] {
        let grades = viewModel.students.map { $0.grade }
        return Array(Set(grades)).sorted()
    }
    
    // Filtered students with all filters applied
    var filteredStudents: [Student] {
        var result = viewModel.filteredStudents
        if let classId = selectedClassId, !classId.isEmpty {
            result = result.filter { student in
                student.enrollments.contains { $0.classId == classId }
            }
        }
        if let grade = selectedGrade, !grade.isEmpty {
            result = result.filter { $0.grade == grade }
        }
        if !searchText.isEmpty {
            result = result.filter { student in
                student.fullName.lowercased().contains(searchText.lowercased()) ||
                student.email.lowercased().contains(searchText.lowercased()) ||
                student.studentNumber.contains(searchText)
            }
        }
        // Sort
        switch selectedSort {
        case .nameAsc:
            result.sort { $0.fullName < $1.fullName }
        case .nameDesc:
            result.sort { $0.fullName > $1.fullName }
        case .gradeAsc:
            result.sort { $0.grade < $1.grade }
        case .gradeDesc:
            result.sort { $0.grade > $1.grade }
        case .idAsc:
            result.sort { $0.studentNumber < $1.studentNumber }
        case .idDesc:
            result.sort { $0.studentNumber > $1.studentNumber }
        }
        return result
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Add Gradebook button
                NavigationLink(destination: GradebookView()) {
                    Label("View Gradebook", systemImage: "tablecells")
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(appSettings.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.vertical, 8)
                }
                // Filter bar
                HStack(spacing: 12) {
                    // Class filter
                    Menu {
                        Button("All Classes", action: { selectedClassId = nil })
                        Divider()
                        ForEach(classService.classes, id: \ .id) { schoolClass in
                            Button(schoolClass.name, action: { selectedClassId = schoolClass.id })
                        }
                    } label: {
                        HStack {
                            Text(selectedClassId.flatMap { id in classService.classes.first(where: { $0.id == id })?.name } ?? "All Classes")
                            Image(systemName: "chevron.down")
                        }
                        .frame(minWidth: 120, alignment: .leading)
                        .foregroundColor(.primary)
                    }
                    .buttonStyle(PressableButtonStyle())
                    // Grade filter
                    Menu {
                        Button("All Grades", action: { selectedGrade = nil })
                        Divider()
                        ForEach(uniqueGrades, id: \ .self) { grade in
                            Button(grade, action: { selectedGrade = grade })
                        }
                    } label: {
                        HStack {
                            Text(selectedGrade ?? "All Grades")
                            Image(systemName: "chevron.down")
                        }
                        .frame(minWidth: 100, alignment: .leading)
                        .foregroundColor(.primary)
                    }
                    .buttonStyle(PressableButtonStyle())
                    // Sort menu
                    Menu {
                        ForEach(StudentsViewModel.SortOption.allCases) { option in
                            Button(option.rawValue, action: { selectedSort = option })
                        }
                    } label: {
                        HStack {
                            Text("Sort: \(selectedSort.rawValue)")
                            Image(systemName: "arrow.up.arrow.down")
                        }
                        .foregroundColor(.primary)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
                // Search bar
                SearchBar(text: $searchText, placeholder: "Search students...")
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                
                if filteredStudents.isEmpty {
                    VStack(spacing: 24) {
                        Spacer()
                        
                        Image(systemName: "person.2.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(appSettings.accentColor)
                        
                        VStack(spacing: 12) {
                            Text(searchText.isEmpty ? "No Students Yet" : "No Students Found")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(searchText.isEmpty ? 
                                "Start by adding your first student.\nKeep track of their progress!" :
                                "Try adjusting your search criteria.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
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
        .toolbar(.hidden, for: .navigationBar)
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
    @EnvironmentObject var appSettings: AppSettings
    
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
                    .foregroundColor(.primary)
                
                Text(student.email)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Text("ID: \(student.studentNumber)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("Grade: \(student.grade)")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(appSettings.accentColor.opacity(0.12))
                        .foregroundColor(.primary)
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
                            .background(getColorForGrade(avgGrade).opacity(0.10))
                            .foregroundColor(getColorForGrade(avgGrade))
                            .cornerRadius(4)
                        
                        Text(student.letterGrade)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(getColorForGrade(avgGrade))
                    }
                } else {
                    let randomGrade = Double.random(in: 65...95)
                    Text(String(format: "%.1f%%", randomGrade))
                        .font(.headline)
                        .foregroundColor(getColorForGrade(randomGrade))
                    
                    HStack(spacing: 4) {
                        Text(getLevelFromGrade(randomGrade))
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(getColorForGrade(randomGrade).opacity(0.10))
                            .foregroundColor(getColorForGrade(randomGrade))
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
                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
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
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(appSettings.accentColor)
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
