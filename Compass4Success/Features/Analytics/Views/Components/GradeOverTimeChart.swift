import Charts
import Compass4Success
import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
struct GradeOverTimeChart: View {
    let data: [TimeSeriesData]
    let timeFrame: AnalyticsTimeFrame

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Grades Over Time")
                .font(.headline)

            chartContent
        }
    }

    // Extract chart content to a separate computed property
    private var chartContent: some View {
        Chart {
            // Add series data marks
            seriesDataMarks

            // Add a target line at 70% (passing grade)
            passingGradeLine
        }
        .frame(height: 250)
        .chartYScale(domain: 0...100)
        .chartXAxis {
            createXAxis()
        }
        .chartYAxis {
            createYAxis()
        }
        .chartLegend(position: .bottom, alignment: .center)
    }

    // Helper for series data marks
    private var seriesDataMarks: some ChartContent {
        ForEach(data) { series in
            ForEach(series.points) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Grade", point.value)
                )
                .foregroundStyle(by: .value("Student", series.name))
            }
        }
    }

    // Helper for passing grade line
    private var passingGradeLine: some ChartContent {
        RuleMark(y: .value("Passing", 70))
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
            .foregroundStyle(.gray)
            .annotation(position: .trailing) {
                Text("Passing")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
    }

    // Helper for X axis configuration
    private func createXAxis() -> some AxisContent {
        AxisMarks(position: .bottom, values: .automatic()) { _ in
            AxisGridLine()
            AxisTick()
            AxisValueLabel()
        }
    }

    // Helper for Y axis configuration
    private func createYAxis() -> some AxisContent {
        AxisMarks(position: .bottom, values: .automatic()) { _ in
            AxisGridLine()
            AxisTick()
            AxisValueLabel()
        }
    }
}
