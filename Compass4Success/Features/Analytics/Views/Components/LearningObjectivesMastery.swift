import SwiftUI

struct LearningObjectivesMastery: View {
    init() {}
    
    let objectives = [
        (objective: "Understand polynomial functions", mastery: 0.85),
        (objective: "Apply quadratic formula", mastery: 0.76),
        (objective: "Graph equations accurately", mastery: 0.92),
        (objective: "Solve word problems", mastery: 0.68)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Learning Objectives Mastery")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(objectives, id: \.objective) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.objective)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(Int(item.mastery * 100))%")
                                .font(.subheadline)
                                .foregroundColor(masteryColor(item.mastery))
                        }
                        
                        ProgressBar(value: item.mastery, color: masteryColor(item.mastery))
                            .frame(height: 8)
                    }
                }
            }
            
            HStack(spacing: 16) {
                masteryLegendItem(range: "85-100%", color: .green, label: "Mastered")
                masteryLegendItem(range: "70-84%", color: .blue, label: "Proficient")
                masteryLegendItem(range: "< 70%", color: .orange, label: "Developing")
            }
            .font(.caption)
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func masteryColor(_ value: Double) -> Color {
        switch value {
        case 0.85...1.0: return .green
        case 0.7..<0.85: return .blue
        default: return .orange
        }
    }
    
    private func masteryLegendItem(range: String, color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                Text(range)
                    .font(.caption2)
            }
            .foregroundColor(.secondary)
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
    LearningObjectivesMastery()
} 