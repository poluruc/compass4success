import SwiftUI
import Charts

struct TeacherAnalyticsView: View {
    let teacher: Teacher
    private let analyticsService = AnalyticsService()
    @State private var isLoading = false
    @State private var selectedTimeFrame: AnalyticsView.TimeFrame = .semester
    
    // Mock data
    @State private var classPerformance: [ChartDataPoint] = []
    @State private var assignmentCompletion: [ChartDataPoint] = []
    @State private var studentProgress: [ChartDataPoint] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Teacher header info
                teacherHeader
                
                // Time frame picker
                timeFramePicker
                
                // Class performance chart
                classPerformanceChart
                
                // Assignment stats
                assignmentStatsChart
                
                // Student progress metrics
                studentProgressChart
                
                // Insights
                insightsView
            }
            .padding(.vertical)
        }
        .navigationTitle("Teacher Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            isLoading ? LoadingOverlay() : nil
        )
        .onAppear {
            loadData()
        }
    }
    
    private var teacherHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(teacher.fullName)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                Label {
                    Text("\(teacher.classes.count) Classes")
                } icon: {
                    Image(systemName: "book.closed.fill")
                }
                .font(.subheadline)
                
                Spacer()
                
                Label {
                    Text("\(teacher.studentCount) Students")
                } icon: {
                    Image(systemName: "person.3.fill")
                }
                .font(.subheadline)
            }
            
            if !teacher.subjects.isEmpty {
                Text("Subjects: \(teacher.subjects.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
    
    private var timeFramePicker: some View {
        HStack {
            Text("Time Period:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            ForEach(AnalyticsView.TimeFrame.allCases, id: \.self) { timeFrame in
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
    
    private var classPerformanceChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Class Performance")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(classPerformance) { item in
                    BarMark(
                        x: .value("Class", item.label),
                        y: .value("Average Grade", item.value)
                    )
                    .foregroundStyle(getGradeColor(item.value))
                    .annotation(position: .top) {
                        Text("\(Int(item.value))%")
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
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    private var assignmentStatsChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Assignment Completion")
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
    }
    
    private var studentProgressChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Student Progress")
                .font(.headline)
                .padding(.horizontal)
            
            VStack {
                ForEach(studentProgress.prefix(5)) { item in
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
            Text("Teaching Insights")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                InsightCard(
                    title: "Biology Class Needs Attention",
                    description: "Average grades have dropped 7% in the last month",
                    icon: "exclamationmark.triangle.fill",
                    color: .orange
                )
                
                InsightCard(
                    title: "Assignment Completion Improving",
                    description: "On-time submissions increased by 12% this semester",
                    icon: "arrow.up.right",
                    color: .green
                )
                
                InsightCard(
                    title: "High Performer Identified",
                    description: "Emily Johnson shows exceptional progress across all subjects",
                    icon: "star.fill",
                    color: .yellow
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
        
        // Generate mock class performance data
        classPerformance = [
            ChartDataPoint(label: "Biology", value: Double.random(in: 75...85)),
            ChartDataPoint(label: "Chemistry", value: Double.random(in: 70...90)),
            ChartDataPoint(label: "Physics", value: Double.random(in: 65...80)),
            ChartDataPoint(label: "Earth Sci", value: Double.random(in: 75...95))
        ]
        
        // Generate mock assignment data
        assignmentCompletion = [
            ChartDataPoint(label: "Completed", value: Double.random(in: 150...250)),
            ChartDataPoint(label: "Late", value: Double.random(in: 30...80)),
            ChartDataPoint(label: "Missing", value: Double.random(in: 10...40))
        ]
        
        // Generate mock student progress data
        studentProgress = [
            ChartDataPoint(label: "John Smith", value: Double.random(in: 80...95)),
            ChartDataPoint(label: "Emily Johnson", value: Double.random(in: 85...98)),
            ChartDataPoint(label: "Michael Williams", value: Double.random(in: 70...85)),
            ChartDataPoint(label: "Olivia Brown", value: Double.random(in: 75...90)),
            ChartDataPoint(label: "James Davis", value: Double.random(in: 65...80))
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

// Reusing InsightCard from StudentAnalyticsView

// Teacher model (simplified version for the view)
struct Teacher: Identifiable {
    var id: String
    var firstName: String
    var lastName: String
    var subjects: [String]
    var classes: [SchoolClass]
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    var studentCount: Int {
        var uniqueStudents = Set<String>()
        for schoolClass in classes {
            for student in schoolClass.students {
                uniqueStudents.insert(student.id)
            }
        }
        return uniqueStudents.count
    }
    
    // Convenience initializer for previews
    static func mock() -> Teacher {
        let mockData = MockDataService.shared.generateMockData()
        return Teacher(
            id: "T001",
            firstName: "Robert",
            lastName: "Jones",
            subjects: ["Mathematics", "Science"],
            classes: Array(mockData.classes.prefix(3))
        )
    }
}

struct TeacherAnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TeacherAnalyticsView(teacher: Teacher.mock())
        }
    }
}