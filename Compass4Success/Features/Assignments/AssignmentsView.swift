import SwiftUI

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
        for schoolClass in classService.classes {
            assignments.append(contentsOf: Array(schoolClass.assignments))
        }
        return assignments
    }
    
    // Filtered assignments based on search, class, and category
    private var filteredAssignments: [Assignment] {
        var filtered = allAssignments
        
        // Apply class filter
        if let filterClass = filterClass {
            filtered = filtered.filter { $0.classId == filterClass.id }
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
                                NavigationLink(destination: AssignmentDetailView(assignment: assignment)) {
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
                AssignmentsAddView(classes: classService.classes)
            }
            .platformPresentationDetent()
        }
        .onAppear {
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
                    .foregroundColor(.primary)
                
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
            NavigationView {
                FiltersView(
                    classFilter: $classFilter,
                    categoryFilter: $categoryFilter,
                    classes: classes
                )
            }
            #if os(iOS)
            .presentationDetents([.height(300)])
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
                
                Text("\(assignment.totalPoints.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(assignment.totalPoints)) : String(format: "%.2f", assignment.totalPoints))) pts")
                    .font(.subheadline)
                    .padding(6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
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

// Rename to avoid duplicate declarations
struct AssignmentsAddView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date().addingTimeInterval(86400 * 7) // 1 week from now
    @State private var selectedClassId = ""
    @State private var category = AssignmentCategory.assignment
    @State private var points = "100"
    @State private var selectedRubric: RubricTemplate? = nil
    @State private var showingRubricPicker = false
    let classes: [SchoolClass]
    let rubrics = RubricLoader.loadAllRubrics()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Assignment Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                        .lineLimit(4)
                    Picker("Class", selection: $selectedClassId) {
                        Text("Select a class").tag("")
                        ForEach(classes) { schoolClass in
                            Text(schoolClass.name).tag(schoolClass.id)
                        }
                    }
                    Picker("Category", selection: $category) {
                        ForEach(AssignmentCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    TextField("Points", text: $points)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                }
                Section(header: Text("Rubric")) {
                    if let rubric = selectedRubric {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(rubric.title)
                                .font(.headline)
                            Text(rubric.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("No rubric selected")
                            .foregroundColor(.secondary)
                    }
                    Button(action: { showingRubricPicker = true }) {
                        Text(selectedRubric == nil ? "Select Rubric" : "Change Rubric")
                    }
                }
            }
            .navigationTitle("Add Assignment")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Save the assignment, including rubricId if selected
                        dismiss()
                    }
                    .disabled(title.isEmpty || selectedClassId.isEmpty)
                }
            }
            .sheet(isPresented: $showingRubricPicker) {
                RubricPickerView(rubrics: rubrics) { rubric in
                    selectedRubric = rubric
                }
            }
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