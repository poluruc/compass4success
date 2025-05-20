import SwiftUI
import Charts

@available(macOS 13.0, iOS 16.0, *)
struct ClassesView: View {
    @EnvironmentObject private var classService: ClassService
    @EnvironmentObject var appSettings: AppSettings
    @State private var showAddClassSheet = false
    @State private var selectedClass: SchoolClass?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var searchText = ""
    @State private var filterGrade: String? = nil
    @State private var sortOption: SortOption = .nameAsc
    @State private var activeNavigation: String? = nil
    
    enum SortOption: String, CaseIterable, Identifiable {
        case nameAsc = "Name (A-Z)"
        case nameDesc = "Name (Z-A)"
        case gradeAsc = "Grade Level (Low-High)"
        case gradeDesc = "Grade Level (High-Low)"
        case studentsAsc = "Students (Low-High)"
        case studentsDesc = "Students (High-Low)"
        
        var id: String { self.rawValue }
    }
    
    var filteredClasses: [SchoolClass] {
        var result = classService.classes
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.subject.localizedCaseInsensitiveContains(searchText) ||
                $0.courseCode.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply grade filter
        if let gradeFilter = filterGrade, !gradeFilter.isEmpty {
            result = result.filter { $0.gradeLevel == gradeFilter }
        }
        
        // Apply sorting
        result.sort { first, second in
            switch sortOption {
            case .nameAsc:
                return first.name < second.name
            case .nameDesc:
                return first.name > second.name
            case .gradeAsc:
                return first.gradeLevel < second.gradeLevel
            case .gradeDesc:
                return first.gradeLevel > second.gradeLevel
            case .studentsAsc:
                return first.enrollmentCount < second.enrollmentCount
            case .studentsDesc:
                return first.enrollmentCount > second.enrollmentCount
            }
        }
        
        return result
    }
    
    var uniqueGradeLevels: [String] {
        let gradeLevels = classService.classes.map { $0.gradeLevel }
        return Array(Set(gradeLevels)).sorted()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom toolbar
            HStack {
                Button(action: refreshClasses) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(PressableButtonStyle())
                .foregroundColor(appSettings.accentColor)
                
                Spacer()
                
                Text("Classes")
                    .font(.headline)
                    .foregroundColor(appSettings.accentColor)
                
                Spacer()
                
                Button(action: {
                    showAddClassSheet = true
                }) {
                    Label("Add", systemImage: "plus")
                        .foregroundColor(appSettings.accentColor)
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding()
            
            // Search and filter bar
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search classes", text: $searchText)
                        .disableAutocorrection(true)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                HStack {
                    Menu {
                        Button("All Grades", action: { filterGrade = nil })
                        Divider()
                        ForEach(uniqueGradeLevels, id: \.self) { grade in
                            Button(grade, action: { filterGrade = grade })
                        }
                    } label: {
                        HStack {
                            Text(filterGrade ?? "All Grades")
                            Image(systemName: "chevron.down")
                        }
                        .frame(minWidth: 120, alignment: .leading)
                        .foregroundColor(.primary)
                    }
                    .buttonStyle(PressableButtonStyle())
                    
                    Spacer()
                    
                    Menu {
                        ForEach(SortOption.allCases) { option in
                            Button(option.rawValue, action: { sortOption = option })
                        }
                    } label: {
                        HStack {
                            Text("Sort: \(sortOption.rawValue)")
                            Image(systemName: "arrow.up.arrow.down")
                        }
                        .foregroundColor(.primary)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                .padding(.horizontal, 8)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            ZStack {
                if classService.classes.isEmpty {
                    VStack(spacing: 24) {
                        Spacer()
                        
                        Image(systemName: "book.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(appSettings.accentColor)
                        
                        VStack(spacing: 12) {
                            Text("No Classes Yet")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Start by adding your first class.\nOrganize your teaching schedule!")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        
                        Button(action: {
                            showAddClassSheet = true
                        }) {
                            Label("Add Class", systemImage: "plus.circle.fill")
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
                } else if filteredClasses.isEmpty {
                    VStack(spacing: 24) {
                        Spacer()
                        
                        Image(systemName: "magnifyingglass.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(appSettings.accentColor)
                        
                        VStack(spacing: 12) {
                            Text("No Classes Found")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Try adjusting your search or filters.")
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
                    // Class cards grid/list
                    ScrollView {
                        classCardsGrid
                        NavigationLinks
                    }
                }
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $showAddClassSheet) {
            // This would be implemented as a form to add a new class
            Text("Add Class Form")
                #if os(iOS)
                .presentationDetents([.medium, .large])
                #elseif os(macOS)
                // Check for macOS 13+ at runtime
                .modifier(MacOSPresentationDetentsModifier(detents: [.medium, .large]))
                #endif
        }
        .sheet(item: $selectedClass) { schoolClass in
            // Navigate to detailed class view
            if #available(iOS 16.0, macOS 13.0, *) {
                NavigationStack {
                    ClassDetailView(schoolClass: schoolClass)
                }
                #if os(iOS)
                .presentationDetents([.large, .fraction(0.95)])
                .presentationDragIndicator(.visible)
                #elseif os(macOS)
                .modifier(MacOSPresentationDetentsModifier(detents: [.large, .fraction(0.95)]))
                #endif
            } else {
                // Fallback for older OS versions
                Text("Detailed class view requires iOS 16.0/macOS 13.0 or newer")
                    .padding()
            }
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
        .onAppear {
            refreshClasses()
        }
    }
    
    private func refreshClasses() {
        isLoading = true
        classService.loadClasses()
        isLoading = false
    }
    
    private var classCardsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 320, maximum: 400), spacing: 16)], spacing: 16) {
            ForEach(filteredClasses) { schoolClass in
                ClassCard(
                    schoolClass: schoolClass,
                    onStudentsTapped: { activeNavigation = "students:\(schoolClass.id)" },
                    onGradebookTapped: { activeNavigation = "gradebook:\(schoolClass.id)" }
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedClass = schoolClass
                }
                .pressableCard()
            }
        }
        .padding()
    }
    
    private var NavigationLinks: some View {
        Group {
            ForEach(filteredClasses, id: \.id) { schoolClass in
                studentsNavigationLink(for: schoolClass)
                gradebookNavigationLink(for: schoolClass)
            }
        }
    }
    
    private func studentsNavigationLink(for schoolClass: SchoolClass) -> some View {
        NavigationLink(
            destination: studentsDestination(for: schoolClass),
            tag: "students:\(schoolClass.id)",
            selection: $activeNavigation,
            label: { EmptyView() }
        )
    }
    
    private func gradebookNavigationLink(for schoolClass: SchoolClass) -> some View {
        NavigationLink(
            destination: gradebookDestination(for: schoolClass),
            tag: "gradebook:\(schoolClass.id)",
            selection: $activeNavigation,
            label: { EmptyView() }
        )
    }
    
    private func studentsDestination(for schoolClass: SchoolClass) -> AnyView {
        if let active = activeNavigation, active == "students:\(schoolClass.id)" {
            return AnyView(ClassDetailView(schoolClass: schoolClass))
        } else if let active = activeNavigation, active == "gradebook:\(schoolClass.id)" {
            return AnyView(ClassDetailView(schoolClass: schoolClass))
        } else {
            return AnyView(EmptyView())
        }
    }
    
    private func gradebookDestination(for schoolClass: SchoolClass) -> AnyView {
        if let active = activeNavigation, active == "gradebook:\(schoolClass.id)" {
            return AnyView(ClassDetailView(schoolClass: schoolClass))
        } else if let active = activeNavigation, active == "students:\(schoolClass.id)" {
            return AnyView(ClassDetailView(schoolClass: schoolClass))
        } else {
            return AnyView(EmptyView())
        }
    }
}

struct ClassCard: View {
    let schoolClass: SchoolClass
    var onStudentsTapped: (() -> Void)? = nil
    var onGradebookTapped: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(schoolClass.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Text(schoolClass.courseCode)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(schoolClass.subject)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(subjectColor(for: schoolClass.subject))
                        .frame(width: 40, height: 40)
                    
                    Text(schoolClass.name.prefix(1))
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            
            // Grade level and period
            HStack {
                Label("Grade \(schoolClass.gradeLevel)", systemImage: "graduationcap")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Label("Period \(schoolClass.period)", systemImage: "clock")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            Divider()
            
            // Stats
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(schoolClass.enrollmentCount)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Students")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(schoolClass.activeAssignmentsCount)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Assignments")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let averageGrade = schoolClass.averageGrade {
                        Text(String(format: "%.1f%%", averageGrade * 100))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(gradeColor(for: averageGrade * 100))
                    } else {
                        Text("N/A")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                    }
                    
                    Text("Avg. Grade")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Action buttons
            HStack {
                Button(action: { onStudentsTapped?() }) {
                    Label("Students", systemImage: "person.3")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                
                Spacer()
                
                Button(action: { onGradebookTapped?() }) {
                    Label("Gradebook", systemImage: "list.clipboard")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(.separator), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
    
    // Helper functions for colors
    private func subjectColor(for subject: String) -> Color {
        switch subject.lowercased() {
        case "math", "mathematics":
            return .blue
        case "science", "biology", "chemistry", "physics":
            return .green
        case "english", "literature":
            return .purple
        case "history":
            return .orange
        case "technology", "computer science":
            return .indigo
        case "art":
            return .pink
        case "music":
            return .cyan
        case "physical education", "pe":
            return .red
        default:
            return .gray
        }
    }
    
    private func gradeColor(for grade: Double) -> Color {
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

// ClassDetailView is implemented in ClassDetailView.swift

// A modifier that conditionally applies presentationDetents on macOS 13+
@available(macOS 13.0, *)
struct MacOSPresentationDetentsModifier: ViewModifier {
    let detents: Set<PresentationDetent>
    
    func body(content: Content) -> some View {
        if #available(macOS 13.0, *) {
            content.presentationDetents(detents)
        } else {
            content
        }
    }
}

@available(macOS 13.0, iOS 16.0, *)
struct ClassesView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(macOS 13.0, *) {
            NavigationView {
                ClassesView()
                    .environmentObject(ClassService())
            }
        } else {
            Text("ClassesView requires macOS 13.0 or newer")
        }
    }
}