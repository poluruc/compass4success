import SwiftUI
import Charts

struct StudentAnalyticsView: View {
    let student: Student
    private let analyticsService = AnalyticsService()
    @State private var isLoading = false
    @State private var selectedTab = 0
    
    // Mock data for charts
    @State private var courseGrades: [ChartDataPoint] = []
    @State private var assignmentCompletion: [ChartDataPoint] = []
    @State private var gradeOverTime: [TimeSeriesDataPoint] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Student info header
                studentHeader
                
                // Tab selector for different metrics
                Picker("Analytics View", selection: $selectedTab) {
                    Text("Overview").tag(0)
                    Text("Assignments").tag(1)
                    Text("Progress").tag(2)
                    Text("Attendance").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Content changes based on selected tab
                if selectedTab == 0 {
                    overviewContent
                } else if selectedTab == 1 {
                    assignmentsContent
                } else if selectedTab == 2 {
                    progressContent
                } else {
                    attendanceContent
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Student Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            isLoading ? LoadingOverlay() : nil
        )
        .onAppear {
            loadData()
        }
    }
    
    private var studentHeader: some View {
        HStack(spacing: 16) {
            // Student avatar
            ZStack {
                Circle()
                    .fill(getColorForName(student.fullName))
                    .frame(width: 60, height: 60)
                
                Text(student.initials)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // Student details
            VStack(alignment: .leading, spacing: 4) {
                Text(student.fullName)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("Grade \(student.grade) • ID: \(student.studentNumber)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let avgGrade = student.averageGrade {
                    HStack(spacing: 6) {
                        Text("Average: \(String(format: "%.1f%%", avgGrade))")
                            .font(.headline)
                            .foregroundColor(getGradeColor(avgGrade))
                        
                        Text(student.letterGrade)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(getGradeColor(avgGrade).opacity(0.2))
                            )
                            .foregroundColor(getGradeColor(avgGrade))
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    private var overviewContent: some View {
        VStack(spacing: 20) {
            // Course performance chart
            VStack(alignment: .leading, spacing: 8) {
                Text("Course Performance")
                    .font(.headline)
                    .padding(.horizontal)
                
                Chart {
                    ForEach(courseGrades) { item in
                        BarMark(
                            x: .value("Course", item.label),
                            y: .value("Grade", item.value)
                        )
                        .foregroundStyle(getGradeColor(item.value))
                        .annotation(position: .top) {
                            Text("\(Int(item.value))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 250)
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .padding(.horizontal)
            
            // Quick stats
            VStack(alignment: .leading, spacing: 8) {
                Text("Academic Highlights")
                    .font(.headline)
                    .padding(.horizontal)
                
                HStack {
                    StatCard(
                        title: "Assignments",
                        value: "92%",
                        subtitle: "Completion",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Attendance",
                        value: "97%",
                        subtitle: "Present",
                        icon: "calendar.badge.clock",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Trend",
                        value: "+3%",
                        subtitle: "vs. Last Month",
                        icon: "arrow.up.right",
                        color: .purple
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
            
            // Insights
            insightsView
        }
    }
    
    private var assignmentsContent: some View {
        VStack(spacing: 20) {
            // Assignment completion chart
            VStack(alignment: .leading, spacing: 8) {
                Text("Assignment Status")
                    .font(.headline)
                    .padding(.horizontal)
                
                Chart {
                    ForEach(assignmentCompletion) { item in
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
                .frame(height: 250)
                .padding(.horizontal)
                .chartForegroundStyleScale([
                    "Completed": .green,
                    "Late": .orange,
                    "Missing": .red
                ])
            }
            .padding(.vertical)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .padding(.horizontal)
            
            // Assignment list preview
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Assignments")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    ForEach(1...3, id: \.self) { index in
                        AssignmentRow(
                            title: "Assignment \(index)",
                            dueDate: "May \(10 + index), 2025",
                            status: index == 3 ? "Missing" : (index == 2 ? "Late" : "Completed"),
                            score: index == 3 ? nil : "\(Int.random(in: 70...95))%"
                        )
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
    }
    
    private var progressContent: some View {
        VStack(spacing: 20) {
            // Grade over time chart
            VStack(alignment: .leading, spacing: 8) {
                Text("Grade Trend")
                    .font(.headline)
                    .padding(.horizontal)
                
                Chart {
                    ForEach(gradeOverTime) { item in
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("Grade", item.value)
                        )
                        .foregroundStyle(by: .value("Course", item.label))
                        .symbol(by: .value("Course", item.label))
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 250)
                .padding(.horizontal)
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
            .padding(.vertical)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .padding(.horizontal)
            
            // Growth areas
            VStack(alignment: .leading, spacing: 12) {
                Text("Growth Areas")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    StrengthWeaknessRow(
                        title: "Mathematics",
                        description: "Strong performance in algebraic concepts",
                        icon: "plus.circle.fill",
                        color: .green
                    )
                    
                    StrengthWeaknessRow(
                        title: "Essay Writing",
                        description: "Could improve thesis development",
                        icon: "exclamationmark.triangle",
                        color: .orange
                    )
                    
                    StrengthWeaknessRow(
                        title: "Science Labs",
                        description: "Excellent analysis of experimental data",
                        icon: "plus.circle.fill",
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
    }
    
    private var attendanceContent: some View {
        VStack(spacing: 20) {
            Text("Attendance analytics will be displayed here")
                .foregroundColor(.secondary)
                .frame(height: 300)
        }
    }
    
    private var insightsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                InsightCard(
                    title: "Mathematics Excellence",
                    description: "Consistently scores in the top 10% of math assignments",
                    icon: "star.fill",
                    color: .yellow
                )
                
                InsightCard(
                    title: "Late Submissions",
                    description: "3 assignments submitted late in the last month",
                    icon: "clock.fill",
                    color: .orange
                )
                
                InsightCard(
                    title: "Grade Improvement",
                    description: "Overall average has improved by 4% this quarter",
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
    
    // Helper views
    private func loadData() {
        isLoading = true
        
        // Generate mock course grades
        courseGrades = [
            ChartDataPoint(label: "Math", value: Double.random(in: 80...95)),
            ChartDataPoint(label: "Science", value: Double.random(in: 75...90)),
            ChartDataPoint(label: "English", value: Double.random(in: 70...85)),
            ChartDataPoint(label: "History", value: Double.random(in: 75...95)),
            ChartDataPoint(label: "Art", value: Double.random(in: 85...100))
        ]
        
        // Generate mock assignment data
        assignmentCompletion = [
            ChartDataPoint(label: "Completed", value: Double.random(in: 15...25)),
            ChartDataPoint(label: "Late", value: Double.random(in: 3...8)),
            ChartDataPoint(label: "Missing", value: Double.random(in: 0...4))
        ]
        
        // Generate mock grade over time data
        let endDate = Date()
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .month, value: -3, to: endDate)!
        let timeInterval = endDate.timeIntervalSince(startDate) / 10
        var dates: [Date] = []
        
        for i in 0..<10 {
            let date = startDate.addingTimeInterval(timeInterval * Double(i))
            dates.append(date)
        }
        
        // Create course series
        var mathSeries: [TimeSeriesDataPoint] = []
        var scienceSeries: [TimeSeriesDataPoint] = []
        var englishSeries: [TimeSeriesDataPoint] = []
        
        var mathGrade = Double.random(in: 75...85)
        var scienceGrade = Double.random(in: 70...80)
        var englishGrade = Double.random(in: 80...90)
        
        for date in dates {
            // Generate fluctuations
            let mathFluctuation = Double.random(in: -5...5)
            let scienceFluctuation = Double.random(in: -5...5)
            let englishFluctuation = Double.random(in: -5...5)
            
            mathGrade = min(100, max(60, mathGrade + mathFluctuation))
            scienceGrade = min(100, max(60, scienceGrade + scienceFluctuation))
            englishGrade = min(100, max(60, englishGrade + englishFluctuation))
            
            mathSeries.append(TimeSeriesDataPoint(label: "Math", date: date, value: mathGrade))
            scienceSeries.append(TimeSeriesDataPoint(label: "Science", date: date, value: scienceGrade))
            englishSeries.append(TimeSeriesDataPoint(label: "English", date: date, value: englishGrade))
        }
        
        // Combine all series
        gradeOverTime = []
        gradeOverTime.append(contentsOf: mathSeries)
        gradeOverTime.append(contentsOf: scienceSeries)
        gradeOverTime.append(contentsOf: englishSeries)
        
        // Simulate delay for loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            isLoading = false
        }
    }
    
    // Helper function to get a color based on the student name
    private func getColorForName(_ name: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .red, .yellow]
        let hash = abs(name.hashValue) % colors.count
        return colors[hash]
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

// Helper views for this screen
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

struct InsightCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct AssignmentRow: View {
    let title: String
    let dueDate: String
    let status: String
    let score: String?
    
    var statusColor: Color {
        switch status {
        case "Completed":
            return .green
        case "Late":
            return .orange
        case "Missing":
            return .red
        default:
            return .gray
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Due: \(dueDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(status)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(statusColor.opacity(0.2))
                    )
                    .foregroundColor(statusColor)
            }
            
            Spacer()
            
            if let score = score {
                Text(score)
                    .font(.headline)
                    .foregroundColor(getScoreColor(score))
            } else {
                Text("—")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
    
    private func getScoreColor(_ scoreString: String) -> Color {
        if let percentString = scoreString.components(separatedBy: "%").first,
           let score = Double(percentString) {
            switch score {
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
        return .gray
    }
}

struct StrengthWeaknessRow: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

struct StudentAnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        // Create mock student for preview
        let mockStudent = MockDataService.shared.generateMockData().students.first!
        
        NavigationView {
            StudentAnalyticsView(student: mockStudent)
        }
    }
}