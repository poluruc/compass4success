import SwiftUI
import Charts

struct CompletionTrendChart: View {
    let submissions: [Submission]
    
    init(submissions: [Submission]) {
        self.submissions = submissions
    }
    
    private var completionData: [(Date, Int)] {
        let calendar = Calendar.current
        var result: [(Date, Int)] = []
        
        let dueDate = Date().addingTimeInterval(-7 * 86400)
        
        for day in 0..<14 {
            let date = calendar.date(byAdding: .day, value: -14 + day, to: dueDate)!
            
            let submissionsCount = submissions.filter { 
                guard let submittedDate = $0.submittedDate else { return false }
                return submittedDate <= date
            }.count
            
            result.append((date, submissionsCount))
        }
        
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Completion Trend")
                .font(.headline)
            
            if #available(iOS 16.0, macOS 13.0, *) {
                Chart {
                    ForEach(completionData, id: \.0) { item in
                        LineMark(
                            x: .value("Date", item.0),
                            y: .value("Submissions", item.1)
                        )
                        .foregroundStyle(Color.blue.gradient)
                        .symbol {
                            Circle()
                                .fill(.blue)
                                .frame(width: 6, height: 6)
                        }
                    }
                    
                    RuleMark(x: .value("Due Date", completionData.last!.0))
                        .foregroundStyle(.red)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .annotation(position: .top) {
                            Text("Due Date")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            } else {
                Text("Completion trend chart available on iOS 16.0+ and macOS 13.0+")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 16) {
                legendItem(color: .blue, label: "Cumulative Submissions")
                legendItem(color: .red, label: "Due Date")
            }
            .font(.caption)
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    CompletionTrendChart(submissions: [])
} 