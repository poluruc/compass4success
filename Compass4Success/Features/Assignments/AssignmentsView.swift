import SwiftUI

private let mockClasses: [SchoolClass] = [
    SchoolClass(id: "1", name: "Math 9A", clazzCode: "M9A", courseCode: "MTH9A", gradeLevel: "9"),
    SchoolClass(id: "2", name: "Science 10B", clazzCode: "S10B", courseCode: "SCI10B", gradeLevel: "10"),
    SchoolClass(id: "3", name: "English 11C", clazzCode: "E11C", courseCode: "ENG11C", gradeLevel: "11"),
    SchoolClass(id: "4", name: "History 9/10", clazzCode: "H910", courseCode: "HIST910", gradeLevel: "9,10")
]

struct AssignmentsView: View {
    @EnvironmentObject private var classService: ClassService
    @EnvironmentObject private var appSettings: AppSettings
    @State private var searchText = ""
    @State private var selectedAssignment: Assignment? = nil
    @State private var showingAddAssignment = false
    @State private var filterClass: SchoolClass? = nil
    @State private var filterCategory: AssignmentCategory? = nil
    @State private var sortOption: SortOption = .dueDate
    @State private var isLoading = false
    
    enum SortOption: String, CaseIterable {
        case dueDate = "Due Date"
        case title = "Title"
        case category = "Category"
        
        var icon: String {
            switch self {
            case .dueDate: return "calendar"
            case .title: return "textformat"
            case .category: return "tag"
            }
        }
    }
    
    // All assignments from all classes
    private var allAssignments: [Assignment] {
        var assignments: [Assignment] = []
        // MOCK DATA: Add assignments with grades and classes
        if classService.classes.isEmpty {
            // Create mock classes
            let mathClass = SchoolClass(id: "1", name: "Math 9A", clazzCode: "M9A", courseCode: "MTH9A", gradeLevel: "9")
            let scienceClass = SchoolClass(id: "2", name: "Science 10B", clazzCode: "S10B", courseCode: "SCI10B", gradeLevel: "10")
            let englishClass = SchoolClass(id: "3", name: "English 11C", clazzCode: "E11C", courseCode: "ENG11C", gradeLevel: "11")
            let historyClass = SchoolClass(id: "4", name: "History 9/10", clazzCode: "H910", courseCode: "HIST910", gradeLevel: "9,10")
            
            // Load rubrics
            let rubrics = RubricLoader.loadAllRubrics()
            let mathRubric = rubrics.first { $0.title.lowercased().contains("math") || $0.applicableGrades.contains(9) }
            let scienceRubric = rubrics.first { $0.title.lowercased().contains("science") || $0.applicableGrades.contains(10) }
            let essayRubric = rubrics.first { $0.title.lowercased().contains("essay") || $0.title.lowercased().contains("writing") }
            let historyRubric = rubrics.first { $0.title.lowercased().contains("history") || $0.applicableGrades.contains(9) || $0.applicableGrades.contains(10) }
            
            // Create mock assignments with multiple grades/classes/rubrics
            let assignment1 = Assignment()
            assignment1.id = "a1"
            assignment1.title = "Algebra Quiz"
            assignment1.assignmentDescription = "Quiz on algebraic expressions"
            assignment1.dueDate = Date().addingTimeInterval(86400 * 2)
            assignment1.classIds.append(objectsIn: [mathClass.id, historyClass.id])
            assignment1.category = AssignmentCategory.quiz.rawValue
            assignment1.totalPoints = 30
            assignment1.gradeLevels.append(objectsIn: ["9", "10"])
            assignment1.isActive = true
            assignment1.rubricId = mathRubric?.id
            
            let assignment2 = Assignment()
            assignment2.id = "a2"
            assignment2.title = "Lab Report: Acids & Bases"
            assignment2.assignmentDescription = "Lab report for acids and bases experiment"
            assignment2.dueDate = Date().addingTimeInterval(86400 * 5)
            assignment2.classIds.append(objectsIn: [scienceClass.id])
            assignment2.category = AssignmentCategory.lab.rawValue
            assignment2.totalPoints = 40
            assignment2.gradeLevels.append(objectsIn: ["10"])
            assignment2.isActive = true
            assignment2.rubricId = scienceRubric?.id
            
            let assignment3 = Assignment()
            assignment3.id = "a3"
            assignment3.title = "Essay: Shakespeare"
            assignment3.assignmentDescription = "Essay on Shakespeare's works"
            assignment3.dueDate = Date().addingTimeInterval(86400 * 7)
            assignment3.classIds.append(objectsIn: [englishClass.id, historyClass.id])
            assignment3.category = AssignmentCategory.essay.rawValue
            assignment3.totalPoints = 50
            assignment3.gradeLevels.append(objectsIn: ["10", "11"])
            assignment3.isActive = true
            assignment3.rubricId = essayRubric?.id
            
            let assignment4 = Assignment()
            assignment4.id = "a4"
            assignment4.title = "History Project: Ancient Civilizations"
            assignment4.assignmentDescription = "Group project on ancient civilizations for grades 9 and 10."
            assignment4.dueDate = Date().addingTimeInterval(86400 * 10)
            assignment4.classIds.append(objectsIn: [historyClass.id])
            assignment4.category = AssignmentCategory.project.rawValue
            assignment4.totalPoints = 60
            assignment4.gradeLevels.append(objectsIn: ["9", "10"])
            assignment4.isActive = true
            assignment4.rubricId = historyRubric?.id
            
            // Add to mock classes
            mathClass.assignments.append(assignment1)
            scienceClass.assignments.append(assignment2)
            englishClass.assignments.append(assignment3)
            historyClass.assignments.append(assignment4)
            historyClass.assignments.append(assignment1)
            historyClass.assignments.append(assignment3)
            
            assignments.append(contentsOf: [assignment1, assignment2, assignment3, assignment4])
        } else {
            for schoolClass in classService.classes {
                assignments.append(contentsOf: Array(schoolClass.assignments))
            }
        }
        return assignments
    }
    
    // Filtered assignments based on search, class, and category
    private var filteredAssignments: [Assignment] {
        var filtered = allAssignments
        
        // Apply class filter
        if let filterClass = filterClass {
            filtered = filtered.filter { $0.classIds.contains(where: { $0 == filterClass.id }) }
        }
        
        // Apply category filter
        if let filterCategory = filterCategory {
            filtered = filtered.filter { $0.categoryEnum == filterCategory }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.assignmentDescription.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Apply sorting
        switch sortOption {
        case .dueDate:
            filtered.sort { $0.dueDate < $1.dueDate }
        case .title:
            filtered.sort { $0.title < $1.title }
        case .category:
            filtered.sort { $0.category < $1.category }
        }
        
        return filtered
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Add Gradebook button
                NavigationLink(destination: GradebookView()) {
                    Label("View Gradebook", systemImage: "tablecells")
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(appSettings.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.top, 8)
                }
                // Search and filter section
                SearchFilterBar(
                    searchText: $searchText,
                    sortOption: $sortOption,
                    classFilter: $filterClass,
                    categoryFilter: $filterCategory,
                    classes: classService.classes
                )
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                if filteredAssignments.isEmpty {
                    VStack(spacing: 24) {
                        Spacer()
                        
                        Image(systemName: "square.and.pencil.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(appSettings.accentColor)
                        
                        VStack(spacing: 12) {
                            Text("No Assignments Yet")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Start by adding your first assignment.\nTrack progress and stay organized!")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        
                        Button(action: {
                            showingAddAssignment = true
                        }) {
                            Label("Add Assignment", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(appSettings.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    // Assignment list
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredAssignments) { assignment in
                                let detailView = AssignmentDetailView(
                                    viewModel: AssignmentViewModel(assignment: assignment),
                                    assignment: assignment
                                )
                                NavigationLink(destination: detailView) {
                                    AssignmentCard(assignment: assignment)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .edgesIgnoringSafeArea(.bottom)
            
            if isLoading {
                AssignmentsLoadingOverlay()
            }
        }
        .navigationTitle("Assignments")
        .platformNavigationBarTrailing {
            Button(action: { showingAddAssignment = true }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingAddAssignment) {
            NavigationView {
                AssignmentsAddView(classes: mockClasses)
            }
            .platformPresentationDetent()
        }
        .onAppear {
            classService.classes = [] // Force use of mock data
            loadData()
        }
    }
    
    private func loadData() {
        isLoading = true
        // In a real app, this would call a service to load assignment data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
    }
}

struct SearchFilterBar: View {
    @Binding var searchText: String
    @Binding var sortOption: AssignmentsView.SortOption
    @Binding var classFilter: SchoolClass?
    @Binding var categoryFilter: AssignmentCategory?
    let classes: [SchoolClass]
    
    @State private var showingFilters = false
    
    @available(iOS 13.0, macOS 12.0, *)
    var body: some View {
        VStack(spacing: 10) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search assignments...", text: $searchText)
                    .appTextFieldStyle()
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Filter bar
            HStack {
                Text("Filters:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Class filter
                FilterButton(
                    title: classFilter?.name ?? "All Classes",
                    icon: "book.fill",
                    color: .blue,
                    isActive: classFilter != nil,
                    action: { showingFilters = true }
                )
                
                // Category filter
                FilterButton(
                    title: categoryFilter?.rawValue ?? "All Categories",
                    icon: "tag.fill",
                    color: .purple,
                    isActive: categoryFilter != nil,
                    action: { showingFilters = true }
                )
                
                Spacer()
                
                // Sort option picker
                Menu {
                    ForEach(AssignmentsView.SortOption.allCases, id: \.self) { option in
                        Button(action: { sortOption = option }) {
                            Label(option.rawValue, systemImage: option.icon)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                        .font(.caption)
                        .padding(6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            FiltersView(
                classFilter: $classFilter,
                categoryFilter: $categoryFilter,
                classes: mockClasses
            )
            #if os(iOS)
            .presentationDetents([.height(500)])
            #endif
        }
    }
}

struct FilterButton: View {
    let title: String
    let icon: String
    let color: Color
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                
                Text(title)
                    .font(.caption)
                    .lineLimit(1)
                
                if isActive {
                    Image(systemName: "xmark")
                        .font(.caption2)
                }
            }
            .padding(6)
            .background(isActive ? color.opacity(0.2) : Color.gray.opacity(0.1))
            .foregroundColor(isActive ? color : .primary)
            .cornerRadius(8)
        }
    }
}

@available(iOS 13.0, macOS 12.0, *)
struct FiltersView: View {
    @Binding var classFilter: SchoolClass?
    @Binding var categoryFilter: AssignmentCategory?
    let classes: [SchoolClass]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        #if os(macOS)
        if #available(macOS 13.0, *) {
            NavigationStack {
                filtersContent
            }
        } else {
            NavigationView {
                filtersContent
            }
        }
        #else
        NavigationView {
            filtersContent
                .navigationBarTitleDisplayMode(.inline)
        }
        #endif
    }
    
    private var filtersContent: some View {
        Form {
            Section(header: Text("Class")) {
                Button("All Classes") {
                    classFilter = nil
                }
                
                ForEach(classes) { schoolClass in
                    Button(action: {
                        classFilter = schoolClass
                    }) {
                        HStack {
                            Text(schoolClass.name)
                            Spacer()
                            if classFilter?.id == schoolClass.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            
            Section(header: Text("Category")) {
                Button("All Categories") {
                    categoryFilter = nil
                }
                
                ForEach(AssignmentCategory.allCases, id: \.self) { category in
                    Button(action: {
                        categoryFilter = category
                    }) {
                        HStack {
                            Image(systemName: category.iconName)
                                .foregroundColor(category.color)
                            Text(category.rawValue)
                            Spacer()
                            if categoryFilter == category {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle("Filters")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button("Reset") {
                    classFilter = nil
                    categoryFilter = nil
                }
            }
        }
    }
}

@available(iOS 13.0, macOS 12.0, *)
struct AssignmentCard: View {
    let assignment: Assignment
    @EnvironmentObject var appSettings: AppSettings
    
    init(assignment: Assignment) {
        self.assignment = assignment
        print("Assignment '", assignment.title, "' gradeLevels:", assignment.gradeLevels, "classIds:", assignment.classIds)
    }
    
    // Due date formatting and status
    private var dueStatus: (text: String, color: Color) {
        let now = Date()
        
        if assignment.dueDate < now {
            if assignment.isSubmitted {
                return ("Submitted", .blue)
            } else {
                return ("Overdue", .red)
            }
        } else {
            let days = assignment.daysUntilDue
            if days == 0 {
                return ("Due Today", .orange)
            } else if days == 1 {
                return ("Due Tomorrow", .orange)
            } else if days <= 7 {
                return ("Due in \(days) days", .blue)
            } else {
                return ("Due \(assignment.formattedDueDate)", .green)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and category
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(assignment.title)
                        .font(.headline)
                        .foregroundColor(appSettings.accentColor)
                    
                    Text(assignment.categoryEnum.rawValue)
                        .font(.caption)
                        .foregroundColor(appSettings.secondaryColor)
                }
                
                Spacer()
                
                Text("\(assignment.totalPoints.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(assignment.totalPoints)) : String(format: "%.2f", assignment.totalPoints)) pts")
                    .font(.subheadline)
                    .padding(6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
            }
            
            // Grades, Classes, and Rubric as color-coded pills
            HStack(spacing: 6) {
                // Show all grade levels as pills
                if !assignment.gradeLevels.isEmpty {
                    ForEach(Array(assignment.gradeLevels), id: \.self) { grade in
                        Text("Grade \(grade)")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.15))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                    }
                } else {
                    Text("No Grade Assigned")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.15))
                        .foregroundColor(.gray)
                        .cornerRadius(8)
                }
                // Show all classes as pills
                if !assignment.classIds.isEmpty {
                    ForEach(Array(assignment.classIds), id: \.self) { classId in
                        Text(className(for: classId))
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple.opacity(0.15))
                            .foregroundColor(.purple)
                            .cornerRadius(8)
                    }
                } else {
                    Text("No Class Assigned")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.15))
                        .foregroundColor(.gray)
                        .cornerRadius(8)
                }
                if let rubricId = assignment.rubricId, !rubricId.isEmpty {
                    Text("Rubric")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.15))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                }
            }
            
            // Description (if exists)
            if !assignment.assignmentDescription.isEmpty {
                Text(assignment.assignmentDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Divider()
            
            // Due date and submission status
            HStack {
                Label {
                    Text(dueStatus.text)
                        .font(.caption)
                        .foregroundColor(dueStatus.color)
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundColor(dueStatus.color)
                }
                
                Spacer()
                
                HStack {
                    Text("Submissions:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(assignment.submissions.count)")
                        .font(.caption)
                        .bold()
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
    
    // Helper to get class name from id (for mock data)
    private func className(for classId: String) -> String {
        switch classId {
        case "1": return "Math 9A"
        case "2": return "Science 10B"
        case "3": return "English 11C"
        case "4": return "History 9/10"
        default: return "Class \(classId)"
        }
    }
}

// Rename to avoid duplicate declarations
@available(iOS 13.0, macOS 12.0, *)
struct AssignmentsEmptyStateView: View {
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
}

// Rename to avoid duplicate declarations
struct AssignmentsLoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
                .foregroundColor(.white)
        }
    }
}

struct AssignmentsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AssignmentsView()
                .environmentObject(ClassService())
                .environmentObject(AppSettings())
        }
    }
}
