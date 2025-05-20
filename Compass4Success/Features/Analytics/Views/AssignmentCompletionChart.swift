import SwiftUI
import Charts
import Compass4Success

@available(iOS 16.0, macOS 13.0, *)
struct AssignmentCompletionChart: View {
    let data: [ChartDataPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Assignment Completion")
                .font(.headline)
            
            Chart {
                ForEach(data) { item in
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
            .chartForegroundStyleScale([
                "Completed": .green,
                "Late": .orange,
                "Missing": .red
            ])
        }
    }
} 