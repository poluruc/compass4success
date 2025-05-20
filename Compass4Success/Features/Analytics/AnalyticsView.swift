import SwiftUI
import Charts
import RealmSwift

// Move these enums outside the main view so they can be accessed without the @available restriction
enum AnalyticsViewType: String, CaseIterable {
    case gradeDistribution = "Grade Distribution"
    case assignmentCompletion = "Assignment Completion"
    case gradeOverTime = "Grades Over Time"
    case studentPerformance = "Student Performance"
    case attendanceVsGrades = "Attendance vs Grades"
    
    var icon: String {
        switch self {
        case .gradeDistribution: return "chart.bar.fill"
        case .assignmentCompletion: return "checkmark.circle.fill"
        case .gradeOverTime: return "chart.line.uptrend.xyaxis"
        case .studentPerformance: return "person.3.fill"
        case .attendanceVsGrades: return "calendar.badge.clock"
        }
    }
}

enum AnalyticsTimeFrame: String, CaseIterable {
    case month = "30 Days"
    case semester = "Semester"
    case year = "Year"
    case all = "All Time"
}

// Class for holding analytics components that are compatible with both platforms
struct AnalyticsComponents {
    // Placeholder compatibility components can be added here
}

@available(macOS 13.0, iOS 16.0, *)
struct AnalyticsView: View {
    @EnvironmentObject private var classService: ClassService
    @State private var selectedClass: SchoolClass?
    @State private var selectedAnalytic: AnalyticsViewType = .gradeDistribution
    @State private var selectedTimeFrame: AnalyticsTimeFrame = .semester
    @State private var isLoading = false
    @State private var showExportSheet = false
    
    // Mock analytics service
    private let analyticsService = AnalyticsService()
    
    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 0) {
                // Class selector
                classSelector
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                
                Divider()
                
                // Content with scrolling
                ScrollView {
                    VStack(spacing: 20) {
                        // Analytics type selector
                        analyticTypeTabPicker
                            .padding(.vertical, 8)
                        
                        // Time frame selector
                        timeFramePicker
                        
                        // Main chart/visualization area
                        analyticsContentView
                        
                        // Insights section
                        analyticsInsightsView
                        
                        // Action buttons
                        actionButtonsView
                        
                        // Add extra padding at bottom for better scrolling experience
                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(.horizontal)
                }
            }
            
            if isLoading {
                AnalyticsLoadingOverlay()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showExportSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showExportSheet) {
            // Export options sheet
            ExportOptionsView(
                analyticType: selectedAnalytic,
                onExport: { format in
                    self.performExport(format: format)
                }
            )
        }
    }
    
    // Class selector view
    private var classSelector: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Select Class:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Menu {
                Button("All Classes") {
                    selectedClass = nil
                    loadAnalyticsData()
                }
                
                ForEach(classService.classes) { class_ in
                    Button(class_.name) {
                        selectedClass = class_
                        loadAnalyticsData()
                    }
                }
            } label: {
                HStack {
                    Text(selectedClass?.name ?? "All Classes")
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(10)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            }
        }
    }
    
    // Analytics type picker styled like QuickStats in a 2-column grid
    private var analyticTypeTabPicker: some View {
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
        
        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(AnalyticsViewType.allCases, id: \.self) { type in
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: type.icon)
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(colorForAnalyticType(type))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        VStack(alignment: .leading) {
                            Text(type.rawValue)
                                .font(.headline)
                                .lineLimit(1)
                        }
                        
                        Spacer(minLength: 0)
                    }
                    .padding(.bottom, 2)
                    
                    // Description based on analytic type
                    Text(descriptionForAnalyticType(type))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer(minLength: 0)
                }
                .padding()
                .frame(height: 100) // Fixed height for consistency
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(selectedAnalytic == type ? colorForAnalyticType(type) : Color.clear, lineWidth: 2)
                )
                .onTapGesture {
                    withAnimation {
                        selectedAnalytic = type
                        isLoading = true
                        loadAnalyticsData()
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // Time frame selector
    private var timeFramePicker: some View {
        HStack(spacing: 10) {
            ForEach(AnalyticsTimeFrame.allCases, id: \.self) { timeFrame in
                Button(action: {
                    selectedTimeFrame = timeFrame
                    isLoading = true
                    loadAnalyticsData()
                }) {
                    Text(timeFrame.rawValue)
                        .font(.subheadline)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(
                            selectedTimeFrame == timeFrame ?
                                Color.blue :
                                Color(.secondarySystemBackground)
                        )
                        .foregroundColor(
                            selectedTimeFrame == timeFrame ?
                                .white :
                                .primary
                        )
                        .cornerRadius(15)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // Main analytics content view that changes based on selected type
    private var analyticsContentView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Different chart based on selected analytics type
            switch selectedAnalytic {
            case .gradeDistribution:
                gradeDistributionChart
                
            case .assignmentCompletion:
                assignmentCompletionChart
                
            case .gradeOverTime:
                gradeOverTimeChart
                
            case .studentPerformance:
                studentPerformanceChart
                
            case .attendanceVsGrades:
                attendanceVsGradesChart
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    // MARK: - Chart Views
    
    private var gradeDistributionChart: some View {
        if #available(iOS 16.0, macOS 13.0, *) {
            let data = analyticsService.getGradeDistribution(classId: selectedClass?.id)
            return GradeDistributionChart(data: data)
        } else {
            return Text("Charts require iOS 16.0/macOS 13.0 or later")
                .frame(height: 250)
        }
    }
    
    private var assignmentCompletionChart: some View {
        if #available(iOS 16.0, macOS 13.0, *) {
            let data = analyticsService.getAssignmentCompletionData(classId: selectedClass?.id)
            return AssignmentCompletionChart(data: data)
        } else {
            return Text("Charts require iOS 16.0/macOS 13.0 or later")
                .frame(height: 250)
        }
    }
    
    private var gradeOverTimeChart: some View {
        if #available(iOS 16.0, macOS 13.0, *) {
            let data = analyticsService.getGradesOverTimeData(classId: selectedClass?.id, timeFrame: selectedTimeFrame)
            return GradeOverTimeChart(data: data, timeFrame: selectedTimeFrame)
        } else {
            return Text("Charts require iOS 16.0/macOS 13.0 or later")
                .frame(height: 250)
        }
    }
    
    private var studentPerformanceChart: some View {
        // We'll use a simple approach to fix the type issues
        var students: [Student] = []
        if let classStudents = selectedClass?.students {
            // Convert Realm Results to Array
            students = classStudents.map { $0 }
        } else {
            students = mockStudents
        }
        
        return VStack(alignment: .leading, spacing: 15) {
            Text("Student Performance")
                .font(.headline)
            
            ForEach(students.sorted(by: { $0.firstName < $1.firstName }).prefix(8), id: \.id) { student in
                studentPerformanceRow(student: student)
            }
            
            if students.count > 8 {
                Button(action: {
                    // Navigate to detailed student performance view
                }) {
                    Text("View All Students")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 5)
                }
            }
        }
    }
    
    private func studentPerformanceRow(student: Student) -> some View {
        // Generate a random grade for demo purposes
        let grade = Double.random(in: 71...95)
        let color: Color = {
            if grade >= 90 { return .green }
            else if grade >= 80 { return .blue }
            else if grade >= 70 { return .yellow }
            else if grade >= 60 { return .orange }
            else { return .red }
        }()
        
        return HStack {
            Text("\(student.firstName) \(student.lastName)")
                .frame(width: 140, alignment: .leading)
                .lineLimit(1)
            
            Spacer()
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: geometry.size.width, height: 20)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * (grade / 100), height: 20)
                    
                    Text("\(Int(grade))%")
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(width: geometry.size.width, height: 20, alignment: .center)
                }
            }
            .frame(height: 20)
            .cornerRadius(5)
        }
        .frame(height: 30)
    }
    
    private var attendanceVsGradesChart: some View {
        if #available(iOS 16.0, macOS 13.0, *) {
            let data = analyticsService.getAttendanceVsGradesData(classId: selectedClass?.id)
            
            return VStack(alignment: .leading, spacing: 8) {
                Text("Attendance vs. Grades")
                    .font(.headline)
                
                Chart {
                    ForEach(data) { point in
                        PointMark(
                            x: .value("Attendance", point.x),
                            y: .value("Grade", point.y)
                        )
                        .annotation(position: .top) {
                            Text(point.label.split(separator: " ").first?.description ?? "")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 250)
                .chartXScale(domain: 70...100)
                .chartYScale(domain: 60...100)
                .chartXAxis {
                    AxisMarks(position: .bottom, values: .automatic()) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic()) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartXAxisLabel("Attendance (%)")
                .chartYAxisLabel("Grade (%)")
            }
        } else {
            return Text("Charts require iOS 16.0/macOS 13.0 or later")
                .frame(height: 250)
        }
    }
    
    // MARK: - Insights View
    
    private var analyticsInsightsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.headline)
            
            ForEach(getInsightsForCurrentAnalytic()) { insight in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: insight.icon)
                        .foregroundColor(insight.color)
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(insight.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(insight.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    // MARK: - Action Buttons
    
    private var actionButtonsView: some View {
        HStack(spacing: 15) {
            Button(action: {
                // Export analytics data
                showExportSheet = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Button(action: {
                // Save to favorites or share
            }) {
                HStack {
                    Image(systemName: "star")
                    Text("Save")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadAnalyticsData() {
        // Simulate data loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
        }
    }
    
    private func getInsightsForCurrentAnalytic() -> [AnalyticsInsight] {
        return analyticsService.getInsights(
            for: selectedAnalytic,
            timeFrame: selectedTimeFrame,
            classId: selectedClass?.id
        )
    }
    
    private func performExport(format: ExportFormat) {
        // Perform export based on selected format
        isLoading = true
        
        // Simulate export process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            // In a real app, this would trigger the actual export
        }
    }
    
    private func colorForAnalyticType(_ type: AnalyticsViewType) -> Color {
        switch type {
        case .gradeDistribution:
            return .blue
        case .assignmentCompletion:
            return .green
        case .gradeOverTime:
            return .orange
        case .studentPerformance:
            return .purple
        case .attendanceVsGrades:
            return .red
        }
    }
    
    private func descriptionForAnalyticType(_ type: AnalyticsViewType) -> String {
        switch type {
        case .gradeDistribution:
            return "View how grades are distributed across your class"
        case .assignmentCompletion:
            return "Track assignment completion rates and status"
        case .gradeOverTime:
            return "Analyze grade trends over selected time period"
        case .studentPerformance:
            return "Compare individual student performance metrics"
        case .attendanceVsGrades:
            return "Correlate attendance patterns with academic performance"
        }
    }
    
    // Mock data for previews
    private var mockStudents: [Student] {
        let students: [Student] = [
            {
                let student = Student()
                student.id = "1"
                student.firstName = "Benjamin"
                student.lastName = "Wilson"
                student.studentNumber = "S1001"
                student.grade = "9"
                return student
            }(),
            {
                let student = Student()
                student.id = "2"
                student.firstName = "John"
                student.lastName = "Smith"
                student.studentNumber = "S1002"
                student.grade = "9"
                return student
            }(),
            {
                let student = Student()
                student.id = "3"
                student.firstName = "James"
                student.lastName = "Davis"
                student.studentNumber = "S1003"
                student.grade = "9"
                return student
            }(),
            {
                let student = Student()
                student.id = "4"
                student.firstName = "Isabella"
                student.lastName = "Anderson"
                student.studentNumber = "S1004"
                student.grade = "9"
                return student
            }(),
            {
                let student = Student()
                student.id = "5"
                student.firstName = "Ava"
                student.lastName = "Moore"
                student.studentNumber = "S1005"
                student.grade = "9"
                return student
            }()
        ]
        return students
    }
}

// MARK: - Supporting Structures

// Used for export functionality

// Export options view
struct ExportOptionsView: View {
    let analyticType: AnalyticsViewType
    let onExport: (ExportFormat) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Export Format")) {
                    ForEach(ExportFormat.allCases) { format in
                        Button(action: {
                            onExport(format)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: format.icon)
                                    .foregroundColor(.blue)
                                
                                Text(format.rawValue)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section(header: Text("Options"), footer: Text("Additional options like date ranges and specific metrics can be configured.")) {
                    Toggle("Include Student Names", isOn: .constant(true))
                    Toggle("Show Detailed Metrics", isOn: .constant(true))
                    Toggle("Include Visualizations", isOn: .constant(true))
                    Toggle("Grade Breakdown", isOn: .constant(true))
                    Toggle("Teacher Notes", isOn: .constant(true))
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Export \(analyticType.rawValue)")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct AnalyticTypeButton: View {
    let type: AnalyticsViewType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 20))
                
                Text(type.rawValue)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 100, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .foregroundColor(isSelected ? .blue : .primary)
        }
    }
}

// Loading overlay view
struct AnalyticsLoadingOverlay: View {
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

@available(macOS 13.0, iOS 16.0, *)
struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(macOS 13.0, *) {
            NavigationView {
                AnalyticsView()
                    .environmentObject(ClassService())
            }
        } else {
            Text("Analytics requires macOS 13.0 or newer")
        }
    }
}