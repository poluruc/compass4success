import SwiftUI
import Charts

struct TimeSeriesChart: View {
    var data: [TimeSeriesDataPoint]
    var title: String = "Trend Analysis"
    var yAxisLabel: String = "Value"
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    var minY: Double = 0
    var maxY: Double = 100
    var height: CGFloat = 250
    var showLegend: Bool = true
    
    // Get unique series labels to create a legend
    private var uniqueSeries: [String] {
        Array(Set(data.map { $0.label })).sorted()
    }
    
    // Get color for a specific series
    private func colorForSeries(_ label: String) -> Color {
        let colors: [Color] = [.blue, .green, .red, .orange, .purple, .pink, .yellow]
        let index = abs(label.hashValue) % colors.count
        return colors[index]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !title.isEmpty {
                Text(title)
                    .font(.headline)
            }
            
            Chart {
                ForEach(data) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value(yAxisLabel, item.value)
                    )
                    .foregroundStyle(by: .value("Series", item.label))
                    .symbol(by: .value("Series", item.label))
                    .interpolationMethod(.catmullRom)
                }
            }
            .frame(height: height)
            .chartYScale(domain: minY...maxY)
            .chartForegroundStyleScale(uniqueSeries.reduce(into: [:]) { dict, label in
                dict[label] = colorForSeries(label)
            })
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text("\(Int(doubleValue))")
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 14)) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(dateFormatter.string(from: date))
                                .font(.caption)
                        }
                    }
                }
            }
            
            if showLegend {
                legendView
            }
        }
    }
    
    private var legendView: some View {
        HStack(spacing: 16) {
            ForEach(uniqueSeries, id: \.self) { series in
                HStack(spacing: 4) {
                    Circle()
                        .fill(colorForSeries(series))
                        .frame(width: 8, height: 8)
                    
                    Text(series)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct TimeSeriesChart_Previews: PreviewProvider {
    static var previews: some View {
        TimeSeriesChart(data: generateMockTimeSeriesData())
            .padding()
            .previewLayout(.sizeThatFits)
    }
    
    static func generateMockTimeSeriesData() -> [TimeSeriesDataPoint] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .month, value: -1, to: endDate)!
        let timeInterval = endDate.timeIntervalSince(startDate) / 8
        var dates: [Date] = []
        
        for i in 0...8 {
            let date = startDate.addingTimeInterval(timeInterval * Double(i))
            dates.append(date)
        }
        
        var result: [TimeSeriesDataPoint] = []
        
        // Class Average series
        var avg = 75.0
        for date in dates {
            avg += Double.random(in: -3...3)
            avg = min(max(avg, 60), 95)
            result.append(TimeSeriesDataPoint(label: "Class Average", date: date, value: avg))
        }
        
        // Top Student series
        var top = 90.0
        for date in dates {
            top += Double.random(in: -2...2)
            top = min(max(top, 85), 100)
            result.append(TimeSeriesDataPoint(label: "Top Student", date: date, value: top))
        }
        
        // Struggling Student series
        var bottom = 65.0
        for date in dates {
            bottom += Double.random(in: -4...4)
            bottom = min(max(bottom, 50), 75)
            result.append(TimeSeriesDataPoint(label: "Struggling Student", date: date, value: bottom))
        }
        
        return result
    }
}