import SwiftUI
import Charts

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
            VStack(spacing: 0) {
                // Header with title and filters
                analyticsHeader
                
                // Main content
                ScrollView {
                    VStack(spacing: 20) {
                        // Analytics type selector
                        analyticTypePicker
                        
                        // Time frame selector
                        timeFramePicker
                        
                        // Main chart/visualization area
                        analyticsContentView
                        
                        // Insights section
                        analyticsInsightsView
                        
                        // Action buttons
                        actionButtonsView
                    }
                    .padding()
                }
            }
            
            if isLoading {
                AnalyticsLoadingOverlay()
            }
        }
        .navigationTitle("Analytics")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showExportSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            #endif
        }
        .sheet(isPresented: $showExportSheet) {
            ExportSettingsView(analyticsType: selectedAnalytic, timeFrame: selectedTimeFrame)
        }
        .onAppear {
            loadData()
        }
    }
    
    private var analyticsHeader: some View {
        VStack(spacing: 12) {
            // Class picker
            Picker("Select Class", selection: $selectedClass) {
                Text("All Classes").tag(nil as SchoolClass?)
                
                ForEach(classService.classes) { classItem in
                    Text(classItem.name).tag(classItem as SchoolClass?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.horizontal)
            
            Divider()
        }
        .padding(.top)
    }
    
    private var analyticTypePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(AnalyticsViewType.allCases, id: \.self) { type in
                    AnalyticTypeButton(
                        type: type,
                        isSelected: selectedAnalytic == type,
                        action: {
                            withAnimation {
                                selectedAnalytic = type
                                isLoading = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isLoading = false
                                }
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var timeFramePicker: some View {
        HStack {
            Text("Time Period:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            ForEach(AnalyticsTimeFrame.allCases, id: \.self) { timeFrame in
                Button(action: {
                    withAnimation {
                        selectedTimeFrame = timeFrame
                        isLoading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isLoading = false
                        }
                    }
                }) {
                    Text(timeFrame.rawValue)
                        .font(.caption)
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedTimeFrame == timeFrame ? Color.blue : Color.gray.opacity(0.2))
                        )
                        .foregroundColor(selectedTimeFrame == timeFrame ? .white : .primary)
                }
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var analyticsContentView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(selectedAnalytic.rawValue)
                .font(.headline)
                .padding(.horizontal)
            
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
    
    private var gradeDistributionChart: some View {
        let data = analyticsService.getGradeDistribution(classId: selectedClass?.id)
        
        return Chart {
            ForEach(data) { item in
                BarMark(
                    x: .value("Grade Range", item.label),
                    y: .value("Students", item.value)
                )
                .foregroundStyle(by: .value("Grade Range", item.label))
                .annotation(position: .top) {
                    Text("\(item.value)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(height: 250)
        .chartForegroundStyleScale([
            "A (90-100%)": .green,
            "B (80-89%)": .blue,
            "C (70-79%)": .yellow,
            "D (60-69%)": .orange,
            "F (0-59%)": .red
        ])
    }
    
    private var assignmentCompletionChart: some View {
        let data = analyticsService.getAssignmentCompletionData(classId: selectedClass?.id)
        
        return Chart {
            ForEach(data) { item in
                BarMark(
                    x: .value("Status", item.label),
                    y: .value("Count", item.value)
                )
                .foregroundStyle(by: .value("Status", item.label))
                .annotation(position: .top) {
                    Text("\(item.value)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(height: 250)
        .chartForegroundStyleScale([
            "Completed": .green,
            "Late": .orange,
            "Missing": .red
        ])
    }
    
    private var gradeOverTimeChart: some View {
        let data = analyticsService.getGradeOverTimeData(
            timeFrame: selectedTimeFrame,
            classId: selectedClass?.id
        )
        
        return Chart {
            ForEach(data) { series in
                LineMark(
                    x: .value("Date", series.date),
                    y: .value("Grade", series.value)
                )
                .foregroundStyle(by: .value("Group", series.label))
                .symbol(by: .value("Group", series.label))
                .interpolationMethod(.catmullRom)
            }
        }
        .frame(height: 250)
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 25, 50, 75, 100]) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue)%")
                    }
                }
            }
        }
    }
    
    private var studentPerformanceChart: some View {
        let data = analyticsService.getStudentPerformanceData(classId: selectedClass?.id)
        
        return VStack {
            ForEach(data.prefix(5)) { item in
                HStack {
                    Text(item.label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 100, alignment: .leading)
                    
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 20)
                        
                        Rectangle()
                            .fill(getGradeColor(item.value))
                            .frame(width: CGFloat(item.value) * 2, height: 20)
                        
                        Text("\(Int(item.value))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                    }
                    .cornerRadius(4)
                }
            }
        }
        .frame(height: 250)
    }
    
    private var attendanceVsGradesChart: some View {
        let data = analyticsService.getAttendanceVsGradesData(classId: selectedClass?.id)
        
        return Chart {
            ForEach(data) { item in
                PointMark(
                    x: .value("Attendance %", item.x),
                    y: .value("Grade %", item.y)
                )
                .foregroundStyle(getGradeColor(item.y))
                .annotation {
                    Text(item.label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(height: 250)
        .chartYScale(domain: 0...100)
        .chartXScale(domain: 0...100)
    }
    
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
    
    private var actionButtonsView: some View {
        HStack {
            Button(action: {
                showExportSheet = true
            }) {
                Label("Export Data", systemImage: "square.and.arrow.up")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: {
                // This would show detailed reports in a real app
            }) {
                Label("Detailed Report", systemImage: "doc.text.magnifyingglass")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
            }
        }
    }
    
    // Helper methods
    private func loadData() {
        isLoading = true
        // Simulate loading analytics data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.isLoading = false
        }
    }
    
    private func getGradeColor(_ grade: Double) -> Color {
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
    
    private func getInsightsForCurrentAnalytic() -> [AnalyticsInsight] {
        return analyticsService.getInsights(for: selectedAnalytic, timeFrame: selectedTimeFrame, classId: selectedClass?.id)
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