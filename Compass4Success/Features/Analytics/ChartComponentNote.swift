import SwiftUI
import Charts

// This file contains shared models and utilities for chart components
// Note: Use the canonical types from AnalyticsChartModels for data structures

// Chart utilities and helper functions
struct ChartUtilities {
    // Generate gradient colors based on values
    static func gradientColorsForValues(value: Double, minValue: Double = 0, maxValue: Double = 100) -> Color {
        let normalizedValue = (value - minValue) / (maxValue - minValue)
        
        switch normalizedValue {
        case 0..<0.2:
            return .red
        case 0.2..<0.4:
            return .orange
        case 0.4..<0.6:
            return .yellow
        case 0.6..<0.8:
            return .blue
        default:
            return .green
        }
    }
    
    // Get color for grade value
    static func getGradeColor(_ grade: Double) -> Color {
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
    
    // Get letter grade from percentage
    static func getLetterGrade(_ percentage: Double) -> String {
        switch percentage {
        case 90...100:
            return "A"
        case 80..<90:
            return "B"
        case 70..<80:
            return "C"
        case 60..<70:
            return "D"
        default:
            return "F"
        }
    }
    
    // Format date for chart labels
    static func formatDateForChart(_ date: Date, style: DateFormatter.Style = .short) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// Chart note documentation browser (for use in development and onboarding)
@available(macOS 13.0, iOS 16.0, *)
struct ChartComponentNoteBrowser: View {
    @State private var markdownText = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Chart Components Documentation")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Text(markdownText)
                
                Divider()
                
                Text("Sample Chart Components")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.vertical)
                
                // Sample grade distribution chart
                VStack(alignment: .leading) {
                    Text("Grade Distribution Chart")
                        .font(.headline)
                    
                    GradeDistributionChart(
                        data: [
                            ChartDataPoint(label: "A (90-100%)", value: 12),
                            ChartDataPoint(label: "B (80-89%)", value: 18),
                            ChartDataPoint(label: "C (70-79%)", value: 15),
                            ChartDataPoint(label: "D (60-69%)", value: 7),
                            ChartDataPoint(label: "F (0-59%)", value: 3)
                        ],
                        height: 200
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                
                // Sample time series chart
                VStack(alignment: .leading) {
                    Text("Time Series Chart")
                        .font(.headline)
                    
                    TimeSeriesChart(
                        data: generateMockTimeSeriesData(),
                        height: 200
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
            }
            .padding()
        }
        .onAppear {
            loadMarkdownDocumentation()
        }
    }
    
    private func loadMarkdownDocumentation() {
        if let markdownURL = Bundle.main.url(forResource: "ChartComponentNote", withExtension: "md"),
           let markdown = try? String(contentsOf: markdownURL, encoding: .utf8) {
            markdownText = markdown
        } else {
            markdownText = "Documentation not found."
        }
    }
    
    @available(macOS 13.0, iOS 16.0, *)
    private func generateMockTimeSeriesData() -> [TimeSeriesDataPoint] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .month, value: -6, to: endDate)!
        
        var result: [TimeSeriesDataPoint] = []
        
        // Class Average series
        for month in 0..<6 {
            let date = calendar.date(byAdding: .month, value: month, to: startDate)!
            let value = Double.random(in: 70...85)
            result.append(TimeSeriesDataPoint(
                label: "Class Average",
                date: date,
                value: value
            ))
        }
        
        // School Average series
        for month in 0..<6 {
            let date = calendar.date(byAdding: .month, value: month, to: startDate)!
            let value = Double.random(in: 75...88)
            result.append(TimeSeriesDataPoint(
                label: "School Average",
                date: date,
                value: value
            ))
        }
        
        return result
    }
}
