import SwiftUI

struct PerformanceComparisonChart: View {
    let assignment: Assignment
    
    init(assignment: Assignment) {
        self.assignment = assignment
    }
    
    var classAverages: [String: Double] = [
        "This Assignment": 82.7,
        "Class Average": 78.5,
        "Previous Quiz": 76.3,
        "Course Average": 81.2
    ]
    
    private var sortedEntries: [(String, Double)] {
        return classAverages.sorted { $0.value > $1.value }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance Comparison")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(sortedEntries, id: \.0) { item in
                    HStack {
                        Text(item.0)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f%%", item.1))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(colorForScore(item.1))
                    }
                    
                    ProgressBar(value: item.1 / 100, color: colorForScore(item.1))
                        .frame(height: 8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func colorForScore(_ score: Double) -> Color {
        switch score {
        case 90...100: return .green
        case 80..<90: return .blue
        case 70..<80: return .yellow
        case 60..<70: return .orange
        default: return .red
        }
    }
}

private struct ProgressBar: View {
    var value: Double // Between 0 and 1
    var color: Color = .blue
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(color)
                    .frame(width: geometry.size.width * CGFloat(min(max(value, 0), 1)))
                    .cornerRadius(4)
            }
        }
    }
}

#Preview {
    PerformanceComparisonChart(assignment: Assignment())
} 