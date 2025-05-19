import SwiftUI
import Charts

struct SubjectPerformanceChart: View {
    var data: [SubjectPerformance]
    var showTargetLine: Bool = true
    var targetValue: Double = 80.0
    var height: CGFloat = 250
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Chart {
                ForEach(data) { item in
                    BarMark(
                        x: .value("Subject", item.subject),
                        y: .value("Average Grade", item.averageGrade)
                    )
                    .foregroundStyle(getColorForGrade(item.averageGrade))
                    .annotation(position: .top) {
                        Text("\(Int(item.averageGrade))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if showTargetLine {
                    RuleMark(
                        y: .value("Target", targetValue)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    .foregroundStyle(.gray)
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Target: \(Int(targetValue))%")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(height: height)
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
            
            // Optional additional information
            if data.contains(where: { $0.studentCount > 0 }) {
                Text("Enrollment by Subject")
                    .font(.headline)
                    .padding(.top, 16)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(data) { item in
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
                }
                .frame(height: min(CGFloat(data.count) * 40, 200))
            }
        }
    }
    
    // Helper function to get color based on grade
    private func getColorForGrade(_ grade: Double) -> Color {
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

struct SubjectPerformanceChart_Previews: PreviewProvider {
    static var previews: some View {
        SubjectPerformanceChart(data: [
            SubjectPerformance(subject: "Math", averageGrade: 82, studentCount: 120),
            SubjectPerformance(subject: "Science", averageGrade: 78, studentCount: 110),
            SubjectPerformance(subject: "English", averageGrade: 85, studentCount: 115),
            SubjectPerformance(subject: "History", averageGrade: 79, studentCount: 105),
            SubjectPerformance(subject: "Art", averageGrade: 92, studentCount: 65)
        ])
        .padding()
        .previewLayout(.sizeThatFits)
    }
}