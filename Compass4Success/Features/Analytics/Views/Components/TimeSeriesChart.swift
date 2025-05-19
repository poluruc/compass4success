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
    
    // Create the color scale as KeyValuePairs (not Dictionary) for the chart
    private var seriesColorPairs: KeyValuePairs<String, Color> {
        // Create KeyValuePairs directly without using Dictionary
        var kvPairs: KeyValuePairs<String, Color>
        
        if uniqueSeries.isEmpty {
            kvPairs = ["Default": .blue]
        } else {
            kvPairs = [uniqueSeries[0]: colorForSeries(uniqueSeries[0])]
        }
        
        return kvPairs
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !title.isEmpty {
                Text(title)
                    .font(.headline)
            }
            
            // Use conditional compilation for OS version checking
            #if os(macOS)
            if #available(macOS 13.0, *) {
                chartView
                    .frame(height: height)
            } else {
                fallbackView
                    .frame(height: height)
            }
            #else
            if #available(iOS 16.0, *) {
                chartView
                    .frame(height: height)
            } else {
                fallbackView
                    .frame(height: height)
            }
            #endif
            
            if showLegend {
                legendView
            }
        }
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var chartView: some View {
        Chart {
            chartContent
        }
        .chartYScale(domain: minY...maxY)
        .chartYAxis {
            yAxisContent
        }
        .chartXAxis {
            xAxisContent
        }
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var chartContent: some ChartContent {
        ForEach(data) { item in
            LineMark(
                x: .value("Date", item.date),
                y: .value(yAxisLabel, item.value)
            )
            .foregroundStyle(colorForSeries(item.label))
            .symbol {
                Circle().fill(colorForSeries(item.label))
            }
            .symbolSize(30)
            .interpolationMethod(.catmullRom)
        }
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var yAxisContent: some AxisContent {
        AxisMarks(position: .leading) { value in
            AxisGridLine()
            AxisValueLabel {
                if let doubleValue = value.as(Double.self) {
                    Text("\(Int(doubleValue))")
                }
            }
        }
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var xAxisContent: some AxisContent {
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
    
    private var fallbackView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Chart requires iOS 16+ / macOS 13+")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Time series data points:")
                .font(.subheadline)
                .padding(.top, 8)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(uniqueSeries, id: \.self) { series in
                        Text(series)
                            .fontWeight(.medium)
                            .padding(.top, 4)
                        
                        ForEach(data.filter { $0.label == series }) { point in
                            HStack {
                                Text(dateFormatter.string(from: point.date))
                                Spacer()
                                Text(String(format: "%.1f", point.value))
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 12)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
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

// MARK: - Preview Provider
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
