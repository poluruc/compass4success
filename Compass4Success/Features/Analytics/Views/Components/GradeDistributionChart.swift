import SwiftUI
import Charts

import Foundation

@available(macOS 13.0, iOS 16.0, *)
struct GradeDistributionChart: View {
    var data: [ChartDataPoint]
    var showLegend: Bool = true
    var height: CGFloat = 250
    
    // Standard grade ranges and colors
    private let gradeRanges = [
        "A (90-100%)": Color.green,
        "B (80-89%)": Color.blue,
        "C (70-79%)": Color.yellow,
        "D (60-69%)": Color.orange,
        "F (0-59%)": Color.red
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Chart {
                ForEach(data) { item in
                    BarMark(
                        x: .value("Grade Range", item.label),
                        y: .value("Students", item.value)
                    )
                    .foregroundStyle(getColorForGradeLabel(item.label))
                    .annotation(position: .top) {
                        Text("\(item.value, specifier: "%.0f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: height)
            
            if showLegend {
                legendView
            }
        }
    }
    
    private var legendView: some View {
        HStack(spacing: 16) {
            ForEach(Array(gradeRanges.keys), id: \.self) { gradeRange in
                HStack(spacing: 4) {
                    Circle()
                        .fill(gradeRanges[gradeRange] ?? .gray)
                        .frame(width: 8, height: 8)
                    
                    Text(gradeRange)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
    }
    
    // Helper function to get color based on grade label
    private func getColorForGradeLabel(_ label: String) -> Color {
        for (range, color) in gradeRanges {
            if label.contains(range) {
                return color
            }
        }
        
        // If the label matches directly with a range
        if let color = gradeRanges[label] {
            return color
        }
        
        // Default color for unknown grade labels
        return .gray
    }
}

@available(macOS 13.0, iOS 16.0, *)
struct GradeDistributionChart_Previews: PreviewProvider {
    static var previews: some View {
        GradeDistributionChart(data: [
            ChartDataPoint(label: "A (90-100%)", value: 12),
            ChartDataPoint(label: "B (80-89%)", value: 18),
            ChartDataPoint(label: "C (70-79%)", value: 15),
            ChartDataPoint(label: "D (60-69%)", value: 7),
            ChartDataPoint(label: "F (0-59%)", value: 3)
        ])
        .padding()
        .frame(width: 350, height: 400)
        .previewDisplayName("Grade Distribution Chart")
    }
}