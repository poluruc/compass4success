import SwiftUI
import Charts

struct GradeLevelPerformance: Identifiable {
    var id = UUID()
    var gradeLevel: String
    var averageGrade: Double
    var targetGrade: Double
}

struct SubjectPerformance: Identifiable {
    var id = UUID()
    var subject: String
    var averageGrade: Double
    var studentCount: Int
}

struct GradeLevelAnalyticsView: View {
    private let analyticsService = AnalyticsService()
    @State private var gradeLevelData: [GradeLevelPerformance] = []
    @State private var subjectData: [SubjectPerformance] = []
    @State private var selectedGradeLevel: String? = nil
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Grade level selector
                gradeLevelPicker
                
                // Grade level performance chart
                gradeLevelChart
                
                // Subjects performance chart
                subjectsChart
                
                // Achievement levels chart
                achievementLevelsChart
                
                // Trend analysis
                trendAnalysisView
            }
            .padding()
        }
        .navigationTitle("Grade Level Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            isLoading ? LoadingOverlay() : nil
        )
        .onAppear {
            loadData()
        }
    }
    
    private var gradeLevelPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(gradeLevelData) { gradeData in
                    Button(action: {
                        withAnimation {
                            if selectedGradeLevel == gradeData.gradeLevel {
                                selectedGradeLevel = nil
                            } else {
                                selectedGradeLevel = gradeData.gradeLevel
                            }
                        }
                    }) {
                        Text("Grade \(gradeData.gradeLevel)")
                            .font(.body)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedGradeLevel == gradeData.gradeLevel ? Color.blue : Color.gray.opacity(0.2))
                            )
                            .foregroundColor(selectedGradeLevel == gradeData.gradeLevel ? .white : .primary)
                    }
                }
                
                if selectedGradeLevel != nil {
                    Button(action: {
                        selectedGradeLevel = nil
                    }) {
                        Text("All Grades")
                            .font(.body)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private var filteredGradeLevelData: [GradeLevelPerformance] {
        if let selectedGrade = selectedGradeLevel {
            return gradeLevelData.filter { $0.gradeLevel == selectedGrade }
        } else {
            return gradeLevelData
        }
    }
    
    private var filteredSubjectData: [SubjectPerformance] {
        // In a real app, this would filter subject data by grade level
        return subjectData
    }
    
    private var gradeLevelChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Grade Level Performance")
                .font(.headline)
            
            Chart {
                ForEach(filteredGradeLevelData) { item in
                    BarMark(
                        x: .value("Grade Level", "Grade " + item.gradeLevel),
                        y: .value("Average Grade", item.averageGrade)
                    )
                    .foregroundStyle(
                        getGradeColor(item.averageGrade)
                    )
                    
                    // Target line
                    if !filteredGradeLevelData.isEmpty {
                        RuleMark(
                            y: .value("Target", filteredGradeLevelData[0].targetGrade)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .foregroundStyle(.gray)
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Target: \(Int(filteredGradeLevelData[0].targetGrade))%")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
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
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private var subjectsChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Subject Performance")
                .font(.headline)
            
            Chart {
                ForEach(filteredSubjectData) { item in
                    BarMark(
                        x: .value("Subject", item.subject),
                        y: .value("Average Grade", item.averageGrade)
                    )
                    .foregroundStyle(
                        getGradeColor(item.averageGrade)
                    )
                    .annotation(position: .top) {
                        Text("\(Int(item.averageGrade))%")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }
            }
            .frame(height: 250)
            .chartYScale(domain: 0...100)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private var achievementLevelsChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievement Levels")
                .font(.headline)
            
            // This would be a more complex chart in a real application
            // Using a placeholder for now
            HStack(spacing: 0) {
                ForEach(getAchievementLevelData()) { level in
                    VStack {
                        Text("\(Int(level.value))%")
                            .font(.headline)
                        
                        Rectangle()
                            .fill(level.color)
                            .frame(height: 30)
                        
                        Text(level.label)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical)
            
            Text("Achievement Level Distribution")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            Text("Distribution of students across achievement levels based on state standards.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private var trendAnalysisView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trend Analysis")
                .font(.headline)
            
            ForEach(getTrendInsights()) { insight in
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: insight.icon)
                        .foregroundColor(insight.color)
                        .font(.system(size: 24))
                        .frame(width: 32, height: 32)
                    
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
    
    // Helper methods
    private func loadData() {
        isLoading = true
        // Simulate loading analytics data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.gradeLevelData = self.analyticsService.getGradeLevelPerformance()
            self.subjectData = self.analyticsService.getSubjectPerformance()
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
    
    private struct AchievementLevelData: Identifiable {
        var id = UUID()
        var label: String
        var value: Double
        var color: Color
    }
    
    private func getAchievementLevelData() -> [AchievementLevelData] {
        return [
            AchievementLevelData(label: "Level 4", value: Double.random(in: 20...30), color: .green),
            AchievementLevelData(label: "Level 3", value: Double.random(in: 30...40), color: .blue),
            AchievementLevelData(label: "Level 2", value: Double.random(in: 15...25), color: .yellow),
            AchievementLevelData(label: "Level 1", value: Double.random(in: 10...20), color: .red)
        ]
    }
    
    private func getTrendInsights() -> [AnalyticsInsight] {
        return [
            AnalyticsInsight(
                title: "Grade 11 outperforming target",
                description: "Students in Grade 11 are consistently scoring above target across all subjects.",
                icon: "arrow.up.right",
                color: .green
            ),
            AnalyticsInsight(
                title: "Mathematics needs intervention",
                description: "Math scores are trending below other subjects, particularly in Grade 9.",
                icon: "exclamationmark.triangle",
                color: .orange
            ),
            AnalyticsInsight(
                title: "Year-over-year improvement",
                description: "Average grades have improved 3.5% compared to the same period last year.",
                icon: "chart.line.uptrend.xyaxis",
                color: .blue
            )
        ]
    }
}

struct GradeLevelAnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GradeLevelAnalyticsView()
        }
    }
}