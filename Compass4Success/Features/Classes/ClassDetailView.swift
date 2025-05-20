import SwiftUI
import Charts

@available(macOS 13.0, iOS 16.0, *)
struct ClassDetailView: View {
    let schoolClass: SchoolClass
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ClassDetailViewModel()
    
    // Tabs for the view
    private enum Tab: Int, CaseIterable {
        case overview, students, assignments, grades
        
        var title: String {
            switch self {
            case .overview: return "Overview"
            case .students: return "Students"
            case .assignments: return "Assignments"
            case .grades: return "Grades"
            }
        }
        
        var icon: String {
            switch self {
            case .overview: return "chart.pie.fill"
            case .students: return "person.3.fill"
            case .assignments: return "list.clipboard.fill"
            case .grades: return "chart.bar.fill"
            }
        }
    }
    
    var filteredStudents: [Student] {
        if searchText.isEmpty {
            return Array(schoolClass.students)
        } else {
            return Array(schoolClass.students).filter { student in
                student.fullName.localizedCaseInsensitiveContains(searchText) ||
                student.studentNumber.localizedCaseInsensitiveContains(searchText) ||
                student.email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with class details
            header
                .padding(.bottom)
            
            // Tab view
            tabBar
                .padding(.horizontal)
            
            // Content based on selected tab
            tabContent
                .padding(.top)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            viewModel.loadClassData(for: schoolClass)
        }
    }
    
    // MARK: - Header
    private var header: some View {
        VStack(spacing: 8) {
            // Class info with action buttons aligned
            VStack(spacing: 4) {
                HStack(alignment: .center) {
                    #if os(iOS)
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    #endif
                    
                    Spacer()
                    
                    Text(schoolClass.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Menu {
                        Button(action: {}) {
                            Label("Edit Class", systemImage: "pencil")
                        }
                        
                        Button(action: {}) {
                            Label("Export Data", systemImage: "square.and.arrow.up")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: {}) {
                            Label("Delete Class", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                
                Text(schoolClass.subject)
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    Label("Grade \(schoolClass.gradeLevel)", systemImage: "graduationcap")
                    
                    Label("Room \(schoolClass.roomNumber)", systemImage: "door.right.hand.open")
                    
                    Label("Period \(schoolClass.period)", systemImage: "clock")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 2)
            }
            
            // Quick stats
            HStack(spacing: 0) {
                ClassStatCard(
                    title: "Students",
                    value: "\(schoolClass.enrollmentCount)",
                    icon: "person.3.fill",
                    color: .blue
                )
                
                Divider()
                
                ClassStatCard(
                    title: "Assignments",
                    value: "\(schoolClass.activeAssignmentsCount)",
                    icon: "list.clipboard.fill",
                    color: .purple
                )
                
                Divider()
                
                ClassStatCard(
                    title: "Avg. Grade",
                    value: schoolClass.formattedAverageGrade,
                    icon: "percent",
                    color: .green
                )
            }
            .frame(height: 80)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
    
    // MARK: - Tab Bar
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                Button(action: {
                    withAnimation {
                        selectedTab = tab.rawValue
                    }
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: selectedTab == tab.rawValue ? 16 : 14))
                        
                        Text(tab.title)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .foregroundColor(selectedTab == tab.rawValue ? .blue : .gray)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                switch Tab(rawValue: selectedTab) ?? .overview {
                case .overview:
                    overviewTab
                case .students:
                    studentsTab
                case .assignments:
                    assignmentsTab
                case .grades:
                    gradesTab
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
    
    // MARK: - Overview Tab
    private var overviewTab: some View {
        VStack(spacing: 20) {
            // Class performance summary
            classPerformanceSummaryView
            
            // Attendance chart
            if #available(iOS 16.0, macOS 13.0, *) {
                attendanceChartView
            } else {
                unavailableChartMessage(message: "Attendance chart available on iOS 16.0+ and macOS 13.0+")
            }
            
            // Performance by assignment type chart
            if #available(iOS 16.0, macOS 13.0, *) {
                assignmentTypePerformanceView
            } else {
                unavailableChartMessage(message: "Assignment type performance available on iOS 16.0+ and macOS 13.0+")
            }
            
            // Grade distribution chart
            if #available(iOS 16.0, macOS 13.0, *) {
                gradeDistributionView
            } else {
                unavailableChartMessage(message: "Grade distribution chart available on iOS 16.0+ and macOS 13.0+")
            }
            
            // Standards mastery visualization
            if #available(iOS 16.0, macOS 13.0, *) {
                standardsMasteryView
            } else {
                unavailableChartMessage(message: "Standards mastery chart available on iOS 16.0+ and macOS 13.0+")
            }
            
            // Assignment completion chart
            if #available(iOS 16.0, macOS 13.0, *) {
                assignmentCompletionView
            } else {
                unavailableChartMessage(message: "Assignment completion chart available on iOS 16.0+ and macOS 13.0+")
            }
        }
    }
    
    private var classPerformanceSummaryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Class Performance")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                HStack {
                    PerformanceIndicator(
                        title: "Avg. Grade",
                        value: schoolClass.formattedAverageGrade,
                        icon: "chart.bar.fill",
                        color: .blue,
                        trend: "+2.3%"
                    )
                    
                    PerformanceIndicator(
                        title: "Assignment Completion",
                        value: "\(viewModel.assignmentCompletionRate)%",
                        icon: "checkmark.circle.fill",
                        color: .green,
                        trend: "-1.5%"
                    )
                }
                
                HStack {
                    PerformanceIndicator(
                        title: "At Risk Students",
                        value: "\(viewModel.atRiskStudentsCount)",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange,
                        trend: "+2"
                    )
                    
                    PerformanceIndicator(
                        title: "Missing Submissions",
                        value: "\(viewModel.missingSubmissionsCount)",
                        icon: "xmark.circle.fill",
                        color: .red,
                        trend: "+5"
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var assignmentTypePerformanceView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance by Assignment Type")
                .font(.headline)
                .padding(.horizontal)
            
            assignmentTypePerformanceChart
                .frame(height: 220)
                .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var assignmentTypePerformanceChart: some View {
        Chart {
            ForEach(viewModel.assignmentTypePerformanceData) { item in
                BarMark(
                    x: .value("Type", item.label),
                    y: .value("Average Score", item.value)
                )
                .foregroundStyle(by: .value("Type", item.label))
                .annotation(position: .top) {
                    Text(String(format: "%.1f%%", item.value))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var gradeDistributionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Grade Distribution")
                .font(.headline)
                .padding(.horizontal)
            
            gradeDistributionChart
                .frame(height: 220)
                .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var gradeDistributionChart: some View {
        Chart {
            ForEach(viewModel.gradeDistributionData) { item in
                BarMark(
                    x: .value("Grade", item.label),
                    y: .value("Count", item.value)
                )
                .foregroundStyle(by: .value("Grade", item.label))
            }
        }
        .chartForegroundStyleScale([
            "A": .green,
            "B": .blue,
            "C": .yellow,
            "D": .orange,
            "F": .red
        ])
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var standardsMasteryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Standards Mastery")
                .font(.headline)
                .padding(.horizontal)
            
            standardsMasteryChart
                .frame(height: 250)
                .padding(.horizontal)
            
            Text("Based on \(viewModel.standardsMasteryData.count) curriculum standards")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var standardsMasteryChart: some View {
        Chart {
            ForEach(viewModel.standardsMasteryData) { item in
                BarMark(
                    x: .value("Mastery", item.masteryPercentage),
                    y: .value("Standard", item.standard)
                )
                .foregroundStyle(Color.blue.gradient)
                .annotation(position: .trailing) {
                    Text(String(format: "%.1f%%", item.masteryPercentage))
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var assignmentCompletionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Assignment Completion")
                .font(.headline)
                .padding(.horizontal)
            
            assignmentCompletionChart
                .frame(height: 200)
                .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var attendanceChartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Attendance Trends")
                .font(.headline)
                .padding(.horizontal)
            
            attendanceChart
                .frame(height: 220)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                LegendItem(color: .blue, label: "Daily Attendance")
                LegendItem(color: .green, label: "Weekly Average")
                LegendItem(color: .red, label: "Required (90%)")
            }
            .font(.caption)
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var attendanceChart: some View {
        Chart {
            // Daily attendance data
            ForEach(viewModel.attendanceData) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Attendance", item.percentage)
                )
                .foregroundStyle(.blue)
                .symbol(.circle)
                .symbolSize(6)
            }
            
            // Weekly averages
            ForEach(viewModel.weeklyAttendanceData) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Weekly Avg", item.percentage)
                )
                .lineStyle(StrokeStyle(lineWidth: 3))
                .foregroundStyle(.green)
            }
            
            // Required attendance line
            RuleMark(
                y: .value("Required", 90)
            )
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
            .foregroundStyle(.red)
            .annotation(position: .trailing) {
                Text("90%")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .chartYScale(domain: 70...100)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var assignmentCompletionChart: some View {
        Chart {
            ForEach(viewModel.assignmentCompletionData) { item in
                BarMark(
                    x: .value("Status", item.label),
                    y: .value("Count", item.value)
                )
                .foregroundStyle(by: .value("Status", item.label))
                .annotation(position: .top) {
                    Text("\(Int(item.value))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .chartForegroundStyleScale([
            "Completed": .green,
            "Late": .orange,
            "Missing": .red
        ])
    }
    
    // MARK: - Students Tab
    private var studentsTab: some View {
        VStack(spacing: 16) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search students", text: $searchText)
                    .disableAutocorrection(true)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Student count
            HStack {
                Text("\(filteredStudents.count) Students")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {}) {
                    Label("Add Student", systemImage: "person.badge.plus")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
            }
            
            // Student list
            VStack(spacing: 0) {
                ForEach(filteredStudents) { student in
                    Button(action: {
                        // Navigate to student detail view
                    }) {
                        StudentListItem(student: student)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color(.systemBackground))
                    }
                    .buttonStyle(.plain)
                    
                    if student.id != filteredStudents.last?.id {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
            
            if filteredStudents.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No Students Found")
                        .font(.headline)
                    
                    Text("Try adjusting your search criteria")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            }
        }
    }
    
    // MARK: - Assignments Tab
    private var assignmentsTab: some View {
        VStack(spacing: 16) {
            // Add assignment button
            Button(action: {}) {
                Label("Add Assignment", systemImage: "plus")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            
            // Assignment list
            VStack(alignment: .leading, spacing: 12) {
                Text("Current Assignments")
                    .font(.headline)
                    .padding(.horizontal)
                
                if schoolClass.assignments.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "list.clipboard")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text("No Assignments")
                            .font(.headline)
                        
                        Text("This class doesn't have any assignments yet.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(schoolClass.assignments)) { assignment in
                            NavigationLink(destination: AssignmentDetailView(assignment: assignment)) {
                                AssignmentListItem(assignment: assignment)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if assignment.id != schoolClass.assignments.last?.id {
                                Divider()
                                    .padding(.leading, 60)
                            }
                        }
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
        }
    }
    
    // MARK: - Grades Tab
    private var gradesTab: some View {
        VStack(spacing: 16) {
            // Grade trends
            if #available(iOS 16.0, macOS 13.0, *) {
                gradeOverTimeChartView
            } else {
                unavailableChartMessage(message: "Grade trends chart available on iOS 16.0+ and macOS 13.0+")
            }
            
            // Skill gap analysis
            if #available(iOS 16.0, macOS 13.0, *) {
                skillGapChartView
            } else {
                unavailableChartMessage(message: "Skill gap analysis available on iOS 16.0+ and macOS 13.0+")
            }
            
            // Attendance-Performance correlation
            if #available(iOS 16.0, macOS 13.0, *) {
                attendancePerformanceChartView
            } else {
                unavailableChartMessage(message: "Attendance-performance correlation available on iOS 16.0+ and macOS 13.0+")
            }
            
            // Grade table
            studentGradesTableView
        }
    }
    
    // MARK: - Chart Components
    
    @available(iOS 16.0, macOS 13.0, *)
    private var gradeOverTimeChartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Grade Trends Over Time")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(viewModel.gradeOverTimeData) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Grade", item.value)
                    )
                    .foregroundStyle(by: .value("Series", item.label))
                    .symbol(by: .value("Series", item.label))
                }
            }
            .frame(height: 220)
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var skillGapChartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Skill Gap Analysis")
                .font(.headline)
                .padding(.horizontal)
            
            skillGapChart
                .frame(height: 220)
                .padding(.horizontal)
            
            Text("Analysis of \(viewModel.skillGapData.count) key skills based on assessment data")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var skillGapChart: some View {
        Chart {
            // Skill bar marks
            ForEach(viewModel.skillGapData) { item in
                BarMark(
                    x: .value("Skill", item.skill),
                    y: .value("Score", item.averageScore)
                )
                .foregroundStyle(item.averageScore < item.expectedScore ? Color.orange : Color.green)
            }
            
            // Expected score rule marks
            ForEach(viewModel.skillGapData) { item in
                RuleMark(
                    x: .value("Skill", item.skill),
                    yStart: .value("Start", 0.0),
                    yEnd: .value("Expected", item.expectedScore)
                )
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                .foregroundStyle(.gray)
                .annotation(position: .top) {
                    Text("Expected")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var attendancePerformanceChartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Attendance-Performance Correlation")
                .font(.headline)
                .padding(.horizontal)
            
            attendancePerformanceChart
                .frame(height: 250)
                .padding(.horizontal)
                .chartXScale(domain: 60...100)
                .chartYScale(domain: 60...100)
            
            Text("Each point represents a student. Higher attendance correlates with better performance.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var attendancePerformanceChart: some View {
        Chart {
            // Student data points
            ForEach(viewModel.attendancePerformanceData) { item in
                attendanceDataPoint(for: item)
            }
            
            // Trend line using a series of points
            ForEach(viewModel.trendLineData) { point in
                LineMark(
                    x: .value("Attendance", point.x),
                    y: .value("Grade", point.y)
                )
                .foregroundStyle(.gray.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
            }
        }
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private func attendanceDataPoint(for item: ClassDetailViewModel.AttendancePerformanceDataPoint) -> some ChartContent {
        PointMark(
            x: .value("Attendance %", item.attendancePercentage),
            y: .value("Grade Average", item.averageGrade)
        )
        .foregroundStyle(
            Color(
                hue: 0.6,
                saturation: item.attendancePercentage / 100,
                brightness: 0.8
            )
        )
        .symbolSize(item.attendancePercentage / 10)
    }
    
    private var studentGradesTableView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Student Grades Summary")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                // Header row
                gradesTableHeader
                
                Divider()
                
                // Grade rows
                ForEach(filteredStudents) { student in
                    studentGradeRow(for: student)
                    
                    if student.id != filteredStudents.last?.id {
                        Divider()
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
        }
    }
    
    private var gradesTableHeader: some View {
        HStack {
            Text("Student")
                .fontWeight(.medium)
                .frame(width: 180, alignment: .leading)
            
            Spacer()
            
            Text("Average")
                .fontWeight(.medium)
                .frame(width: 80, alignment: .trailing)
            
            Text("Grade")
                .fontWeight(.medium)
                .frame(width: 60, alignment: .trailing)
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private func studentGradeRow(for student: Student) -> some View {
        HStack {
            Text(student.fullName)
                .frame(width: 180, alignment: .leading)
            
            Spacer()
            
            Text(String(format: "%.1f%%", student.gpa * 100))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundColor(gradeColor(for: student.gpa * 100))
            
            Text(gradeLetterFromPercentage(student.gpa * 100))
                .frame(width: 60, alignment: .trailing)
                .foregroundColor(gradeColor(for: student.gpa * 100))
        }
        .font(.subheadline)
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
    
    private func unavailableChartMessage(message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
    }
    
    // MARK: - Helper methods
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
    
    private func gradeLetterFromPercentage(_ percentage: Double) -> String {
        switch percentage {
        case 90...100: return "A"
        case 80..<90: return "B"
        case 70..<80: return "C"
        case 60..<70: return "D"
        default: return "F"
        }
    }
}

// MARK: - Supporting Views
struct ClassStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PerformanceIndicator: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
                
                HStack(spacing: 2) {
                    Image(systemName: trend.hasPrefix("+") ? "arrow.up" : "arrow.down")
                        .font(.caption2)
                    
                    Text(trend)
                        .font(.caption2)
                }
                .foregroundColor(trend.hasPrefix("+") ? .red : .green)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
        .frame(maxWidth: .infinity)
    }
}

struct StudentListItem: View {
    let student: Student
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(student.profileColor)
                    .frame(width: 40, height: 40)
                
                Text(student.initials)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(student.fullName)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(student.studentNumber)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.1f%%", student.gpa * 100))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(student.academicStandingColor)
                        .frame(width: 8, height: 8)
                    
                    Text("Grade \(student.grade)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .foregroundColor(.secondary)
        }
    }
}

struct AssignmentListItem: View {
    let assignment: Assignment
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(assignment.categoryColor)
                    .frame(width: 40, height: 40)
                
                Image(systemName: assignment.categoryIcon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(assignment.title)
                    .font(.body)
                    .fontWeight(.medium)
                
                HStack(spacing: 8) {
                    Text(assignment.categoryEnum.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(assignment.categoryColor.opacity(0.1))
                        .foregroundColor(assignment.categoryColor)
                        .cornerRadius(4)
                    
                    Text("Due \(formattedDueDate(assignment.dueDate))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(assignment.totalPoints)) pts")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(assignment.submissions.count) submissions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func formattedDueDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - View Model
class ClassDetailViewModel: ObservableObject {
    @Published var gradeDistributionData: [ChartDataPoint] = []
    @Published var assignmentCompletionData: [ChartDataPoint] = []
    @Published var gradeOverTimeData: [TimeSeriesDataPoint] = []
    @Published var assignmentCompletionRate: Int = 85
    @Published var atRiskStudentsCount: Int = 3
    @Published var missingSubmissionsCount: Int = 12
    
    // New data points for additional analytics
    @Published var standardsMasteryData: [StandardMasteryDataPoint] = []
    @Published var assignmentTypePerformanceData: [ChartDataPoint] = []
    @Published var skillGapData: [SkillGapDataPoint] = []
    @Published var attendancePerformanceData: [AttendancePerformanceDataPoint] = []
    @Published var trendLineData: [TrendDataPoint] = []
    @Published var attendanceData: [AttendanceDataPoint] = []
    @Published var weeklyAttendanceData: [AttendanceDataPoint] = []
    
    // Data structures for new analytics
    struct StandardMasteryDataPoint: Identifiable {
        var id = UUID()
        var standard: String
        var masteryPercentage: Double
        var studentCount: Int
    }
    
    struct SkillGapDataPoint: Identifiable {
        var id = UUID()
        var skill: String
        var averageScore: Double
        var expectedScore: Double
        var studentCount: Int
    }
    
    struct AttendancePerformanceDataPoint: Identifiable {
        var id = UUID()
        var student: String
        var attendancePercentage: Double
        var averageGrade: Double
    }
    
    struct TrendDataPoint: Identifiable {
        var id = UUID()
        var x: Double
        var y: Double
    }
    
    struct AttendanceDataPoint: Identifiable {
        var id = UUID()
        var date: Date
        var percentage: Double
    }
    
    func loadClassData(for schoolClass: SchoolClass) {
        // In a real implementation, this would load data from a service
        // For now, we'll just create mock data
        
        // Generate grade distribution data
        gradeDistributionData = [
            ChartDataPoint(label: "A", value: 8),
            ChartDataPoint(label: "B", value: 12),
            ChartDataPoint(label: "C", value: 6),
            ChartDataPoint(label: "D", value: 2),
            ChartDataPoint(label: "F", value: 1)
        ]
        
        // Generate assignment completion data
        assignmentCompletionData = [
            ChartDataPoint(label: "Completed", value: 45),
            ChartDataPoint(label: "Late", value: 12),
            ChartDataPoint(label: "Missing", value: 8)
        ]
        
        // Generate grade over time data
        let calendar = Calendar.current
        let now = Date()
        
        let classAverages = [78.5, 80.1, 82.4, 84.7, 85.2, 83.9]
        let schoolAverages = [75.2, 76.5, 77.8, 78.2, 79.1, 80.0]
        
        gradeOverTimeData = []
        
        for i in 0..<6 {
            let date = calendar.date(byAdding: .day, value: -5 * (5 - i), to: now)!
            
            gradeOverTimeData.append(TimeSeriesDataPoint(
                label: "Class Average",
                date: date,
                value: classAverages[i]
            ))
            
            gradeOverTimeData.append(TimeSeriesDataPoint(
                label: "School Average",
                date: date,
                value: schoolAverages[i]
            ))
        }
        
        // Generate standards mastery data
        standardsMasteryData = [
            StandardMasteryDataPoint(standard: "1.1: Number Properties", masteryPercentage: 92.5, studentCount: 23),
            StandardMasteryDataPoint(standard: "1.2: Algebraic Expressions", masteryPercentage: 85.8, studentCount: 22),
            StandardMasteryDataPoint(standard: "1.3: Equations & Inequalities", masteryPercentage: 78.3, studentCount: 24),
            StandardMasteryDataPoint(standard: "2.1: Functions", masteryPercentage: 72.4, studentCount: 20),
            StandardMasteryDataPoint(standard: "2.2: Linear Functions", masteryPercentage: 88.9, studentCount: 23),
            StandardMasteryDataPoint(standard: "3.1: Data Analysis", masteryPercentage: 65.7, studentCount: 18)
        ]
        
        // Generate assignment type performance data
        assignmentTypePerformanceData = [
            ChartDataPoint(label: "Tests", value: 82.5),
            ChartDataPoint(label: "Quizzes", value: 78.3),
            ChartDataPoint(label: "Homework", value: 88.7),
            ChartDataPoint(label: "Projects", value: 91.2),
            ChartDataPoint(label: "Participation", value: 95.0)
        ]
        
        // Generate skill gap data
        skillGapData = [
            SkillGapDataPoint(skill: "Problem Solving", averageScore: 72.5, expectedScore: 85.0, studentCount: 14),
            SkillGapDataPoint(skill: "Critical Thinking", averageScore: 68.3, expectedScore: 80.0, studentCount: 16),
            SkillGapDataPoint(skill: "Communication", averageScore: 82.7, expectedScore: 75.0, studentCount: 5),
            SkillGapDataPoint(skill: "Research", averageScore: 63.1, expectedScore: 80.0, studentCount: 18),
            SkillGapDataPoint(skill: "Collaboration", averageScore: 88.5, expectedScore: 85.0, studentCount: 4)
        ]
        
        // Generate attendance-performance correlation data
        attendancePerformanceData = [
            AttendancePerformanceDataPoint(student: "Student 1", attendancePercentage: 98.5, averageGrade: 92.3),
            AttendancePerformanceDataPoint(student: "Student 2", attendancePercentage: 95.0, averageGrade: 88.7),
            AttendancePerformanceDataPoint(student: "Student 3", attendancePercentage: 87.2, averageGrade: 82.1),
            AttendancePerformanceDataPoint(student: "Student 4", attendancePercentage: 92.8, averageGrade: 90.5),
            AttendancePerformanceDataPoint(student: "Student 5", attendancePercentage: 78.5, averageGrade: 72.8),
            AttendancePerformanceDataPoint(student: "Student 6", attendancePercentage: 65.3, averageGrade: 61.2),
            AttendancePerformanceDataPoint(student: "Student 7", attendancePercentage: 72.1, averageGrade: 68.9),
            AttendancePerformanceDataPoint(student: "Student 8", attendancePercentage: 88.9, averageGrade: 85.4),
            AttendancePerformanceDataPoint(student: "Student 9", attendancePercentage: 93.7, averageGrade: 91.2),
            AttendancePerformanceDataPoint(student: "Student 10", attendancePercentage: 81.4, averageGrade: 76.3)
        ]
        
        // Generate trend line data for attendance-performance correlation
        trendLineData = [
            TrendDataPoint(x: 60.0, y: 60.0),
            TrendDataPoint(x: 100.0, y: 95.0)
        ]
        
        // Generate attendance data
        // Daily attendance data for past 14 days
        attendanceData = []
        let dailyAttendanceValues: [Double] = [
            92.5, 89.8, 94.2, 95.0, 91.3, 90.8, 88.5,
            93.7, 96.2, 94.8, 92.1, 88.3, 93.5, 97.1
        ]
        
        for i in 0..<14 {
            let date = calendar.date(byAdding: Calendar.Component.day, value: -13 + i, to: now)!
            attendanceData.append(AttendanceDataPoint(
                date: date,
                percentage: dailyAttendanceValues[i]
            ))
        }
        
        // Weekly average attendance data
        weeklyAttendanceData = []
        let weeklyAverages: [Double] = [91.0, 92.5, 94.5]
        
        for i in 0..<3 {
            let date = calendar.date(byAdding: Calendar.Component.day, value: -10 + (i * 5), to: now)!
            weeklyAttendanceData.append(AttendanceDataPoint(
                date: date,
                percentage: weeklyAverages[i]
            ))
        }
    }
} 
