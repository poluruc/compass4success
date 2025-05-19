import SwiftUI
import Charts

@available(macOS 13.0, iOS 16.0, *)
struct SchoolAnalyticsView: View {
    private let analyticsService = AnalyticsService()
    @State private var isLoading = false
    @State private var selectedTimeFrame: AnalyticsTimeFrame = .semester
    @State private var selectedMetric = SchoolMetric.gradeDistribution
    
    // Mock data
    @State private var gradeLevelPerformance: [GradeLevelPerformance] = []
    @State private var subjectPerformance: [SubjectPerformance] = []
    @State private var attendanceData: [ChartDataPoint] = []
    
    enum SchoolMetric: String, CaseIterable {
        case gradeDistribution = "Grade Distribution"
        case subjectPerformance = "Subject Performance"
        case attendance = "Attendance"
        case teacherPerformance = "Teacher Performance"
        
        var icon: String {
            switch self {
            case .gradeDistribution: return "chart.bar.fill"
            case .subjectPerformance: return "book.fill"
            case .attendance: return "calendar.badge.clock"
            case .teacherPerformance: return "person.text.rectangle.fill"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // School info header
                schoolHeader
                
                // Metric selector
                metricSelector
                
                // Time frame picker
                timeFramePicker
                
                // Content based on selected metric
                switch selectedMetric {
                case .gradeDistribution:
                    gradeLevelPerformanceView
                case .subjectPerformance:
                    subjectPerformanceView
                case .attendance:
                    attendanceView
                case .teacherPerformance:
                    teacherPerformanceView
                }
                
                // Insights
                insightsView
            }
            .padding(.vertical)
        }
        .navigationTitle("School Analytics")
        .platformSpecificTitleDisplayMode()    .overlay(
            isLoading ? LoadingOverlay() : nil
        )
        .onAppear {
            loadData()
        }
    }
    
    private var schoolHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Westlake High School")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                Label {
                    Text("825 Students")
                } icon: {
                    Image(systemName: "person.3.fill")
                }
                .font(.subheadline)
                
                Spacer()
                
                Label {
                    Text("42 Teachers")
                } icon: {
                    Image(systemName: "person.2.fill")
                }
                .font(.subheadline)
            }
            
            HStack {
                Label {
                    Text("5 Grade Levels")
                } icon: {
                    Image(systemName: "list.number")
                }
                .font(.subheadline)
                
                Spacer()
                
                Label {
                    Text("85% Graduation Rate")
                } icon: {
                    Image(systemName: "graduationcap.fill")
                }
                .font(.subheadline)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    private var metricSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(SchoolMetric.allCases, id: \.self) { metric in
                    Button(action: {
                        withAnimation {
                            selectedMetric = metric
                            isLoading = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                loadData()
                            }
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: metric.icon)
                                .font(.title2)
                            
                            Text(metric.rawValue)
                                .font(.caption)
                        }
                        .frame(width: 100, height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedMetric == metric ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedMetric == metric ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        )
                        .foregroundColor(selectedMetric == metric ? .blue : .primary)
                    }
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
                            loadData()
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
    
    private var gradeLevelPerformanceView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Grade Level Performance")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(gradeLevelPerformance) { item in
                    BarMark(
                        x: .value("Grade Level", "Grade " + item.gradeLevel),
                        y: .value("Average Grade", item.averageGrade)
                    )
                    .foregroundStyle(getGradeColor(item.averageGrade))
                    .annotation(position: .top) {
                        Text("\(Int(item.averageGrade))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !gradeLevelPerformance.isEmpty {
                    RuleMark(
                        y: .value("Target", gradeLevelPerformance[0].targetGrade)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    .foregroundStyle(.gray)
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Target: \(Int(gradeLevelPerformance[0].targetGrade))%")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(height: 250)
            .padding(.horizontal)
            .chartYScale(domain: 0...100)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    private var subjectPerformanceView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Subject Performance")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(subjectPerformance) { item in
                    BarMark(
                        x: .value("Subject", item.subject),
                        y: .value("Average Grade", item.averageGrade)
                    )
                    .foregroundStyle(getGradeColor(item.averageGrade))
                    .annotation(position: .top) {
                        Text("\(Int(item.averageGrade))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                RuleMark(
                    y: .value("Target", 80)
                )
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                .foregroundStyle(.gray)
                .annotation(position: .top, alignment: .trailing) {
                    Text("Target: 80%")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(height: 250)
            .padding(.horizontal)
            .chartYScale(domain: 0...100)
            
            // Student counts per subject
            Text("Enrollment by Subject")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 16)
            
            VStack(spacing: 12) {
                ForEach(subjectPerformance) { item in
                    HStack {
                        Text(item.subject)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(item.studentCount) students")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    private var attendanceView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Attendance Records")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(attendanceData) { item in
                    BarMark(
                        x: .value("Status", item.label),
                        y: .value("Count", item.value)
                    )
                    .foregroundStyle(by: .value("Status", item.label))
                }
            }
            .frame(height: 250)
            .padding(.horizontal)
            .chartForegroundStyleScale([
                "Present": .green,
                "Late": .yellow,
                "Excused": .blue,
                "Unexcused": .red
            ])
            
            // Attendance percentage
            HStack {
                AttendanceStatCard(
                    title: "Overall",
                    percentage: "94.2%",
                    description: "+2.1% vs last semester",
                    color: .green
                )
                
                AttendanceStatCard(
                    title: "9th Grade",
                    percentage: "92.7%",
                    description: "Lowest attendance rate",
                    color: .yellow
                )
            }
            .padding(.horizontal)
            
            HStack {
                AttendanceStatCard(
                    title: "11th Grade",
                    percentage: "96.5%",
                    description: "Highest attendance rate",
                    color: .green
                )
                
                AttendanceStatCard(
                    title: "Mondays",
                    percentage: "91.3%",
                    description: "Highest absence day",
                    color: .orange
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    private var teacherPerformanceView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Teacher Performance")
                .font(.headline)
                .padding(.horizontal)
            
            // Simplified placeholder
            Text("Teacher performance analytics content will appear here")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, minHeight: 200)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    private var insightsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("School Insights")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                InsightCard(
                    title: "11th Grade Outperforming Peers",
                    description: "The 11th grade has the highest average grades and attendance rates across all subjects",
                    icon: "star.fill",
                    color: .yellow
                )
                
                InsightCard(
                    title: "Math Department Needs Support",
                    description: "Mathematics has the lowest average grades across all grade levels",
                    icon: "exclamationmark.triangle.fill",
                    color: .orange
                )
                
                InsightCard(
                    title: "Attendance Improving",
                    description: "School-wide attendance has increased 2.1% compared to last semester",
                    icon: "arrow.up.right",
                    color: .green
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    // Helper methods
    private func loadData() {
        isLoading = true
        
        // Load grade level performance data
        gradeLevelPerformance = analyticsService.getGradeLevelPerformance()
        
        // Load subject performance data
        subjectPerformance = analyticsService.getSubjectPerformance()
        
        // Generate mock attendance data
        attendanceData = [
            ChartDataPoint(label: "Present", value: Double.random(in: 700...800)),
            ChartDataPoint(label: "Late", value: Double.random(in: 20...50)),
            ChartDataPoint(label: "Excused", value: Double.random(in: 30...60)),
            ChartDataPoint(label: "Unexcused", value: Double.random(in: 10...30))
        ]
        
        // Simulate delay for loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            isLoading = false
        }
    }
    
    // Helper function to get color based on grade
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
}

struct AttendanceStatCard: View {
    let title: String
    let percentage: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(percentage)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

@available(macOS 13.0, iOS 16.0, *)
struct SchoolAnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SchoolAnalyticsView()
        }
    }
}
