import SwiftUI
import Charts

// This file contains shared models and utilities for chart components

// Basic chart data point for bar charts and other simple visualizations
struct ChartDataPoint: Identifiable {
    var id = UUID()
    var label: String
    var value: Double
    
    // Optional color for when individual data points need custom colors
    var color: Color? = nil
}

// Time series data point for tracking changes over time
struct TimeSeriesDataPoint: Identifiable {
    var id = UUID()
    var label: String
    var date: Date
    var value: Double
}

// Data point for scatter plots (e.g., attendance vs grades)
struct ScatterPlotDataPoint: Identifiable {
    var id = UUID()
    var label: String
    var x: Double
    var y: Double
    var size: Double = 8 // Optional size for emphasizing certain points
}

// Model for subject performance analysis
struct SubjectPerformance: Identifiable {
    var id = UUID()
    var subject: String
    var averageGrade: Double
    var studentCount: Int = 0
}

// Model for grade level performance analysis
struct GradeLevelPerformance: Identifiable {
    var id = UUID()
    var gradeLevel: String
    var averageGrade: Double
    var targetGrade: Double = 80
}

// Model for analytics insights
struct AnalyticsInsight: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var icon: String
    var color: Color
}

// Export formats supported by the analytics system
enum ExportFormat: String, CaseIterable {
    case pdf = "PDF"
    case csv = "CSV"
    case excel = "Excel"
    
    var icon: String {
        switch self {
        case .pdf:
            return "doc.viewfinder"
        case .csv:
            return "tablecells"
        case .excel:
            return "tablecells.badge.ellipsis"
        }
    }
    
    var fileExtension: String {
        switch self {
        case .pdf:
            return "pdf"
        case .csv:
            return "csv"
        case .excel:
            return "xlsx"
        }
    }
    
    var mimeType: String {
        switch self {
        case .pdf:
            return "application/pdf"
        case .csv:
            return "text/csv"
        case .excel:
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        }
    }
}

// Reusable loading overlay for chart operations that might take time
struct LoadingOverlay: View {
    var message: String = "Loading..."
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 15) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text(message)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6).opacity(0.8))
            )
        }
    }
}

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
        if let fileURL = Bundle.main.url(forResource: "ChartComponentNote", withExtension: "md"),
           let content = try? String(contentsOf: fileURL) {
            markdownText = content
        } else {
            markdownText = "Documentation not found. Please check that ChartComponentNote.md is included in the project bundle."
        }
    }
    
    private func generateMockTimeSeriesData() -> [TimeSeriesDataPoint] {
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
        
        return result
    }
}