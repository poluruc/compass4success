import SwiftUI
import Charts

struct StudentEngagementChart: View {
    init() {}
    
    let engagementData = [
        (metric: "Avg. Time Spent", value: 28.4, unit: "min", icon: "clock.fill"),
        (metric: "Attempts per Student", value: 1.7, unit: "", icon: "arrow.triangle.2.circlepath"),
        (metric: "Revision Rate", value: 42.0, unit: "%", icon: "pencil"),
        (metric: "Help Requests", value: 5.0, unit: "", icon: "questionmark.circle")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Student Engagement")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(engagementData, id: \.metric) { item in
                    engagementCard(
                        metric: item.metric,
                        value: item.value,
                        unit: item.unit,
                        icon: item.icon
                    )
                }
            }
            
            if #available(iOS 16.0, macOS 13.0, *) {
                timeDistributionChart
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var timeDistributionChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Time Distribution")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.top, 8)
            
            Chart {
                BarMark(
                    x: .value("Range", "< 15 min"),
                    y: .value("Count", 5)
                )
                .foregroundStyle(Color.blue.opacity(0.7))
                
                BarMark(
                    x: .value("Range", "15-30 min"),
                    y: .value("Count", 12)
                )
                .foregroundStyle(Color.blue.opacity(0.8))
                
                BarMark(
                    x: .value("Range", "30-45 min"),
                    y: .value("Count", 8)
                )
                .foregroundStyle(Color.blue.opacity(0.9))
                
                BarMark(
                    x: .value("Range", "> 45 min"),
                    y: .value("Count", 3)
                )
                .foregroundStyle(Color.blue)
            }
            .frame(height: 150)
        }
    }
    
    private func engagementCard(metric: String, value: Double, unit: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.subheadline)
                
                Text(metric)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(String(format: "%.1f", value))
                    .font(.title3)
                    .fontWeight(.bold)
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    StudentEngagementChart()
} 