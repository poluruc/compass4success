import SwiftUI

struct EngagementRadarChart: View {
    let scores: [EngagementScore]
    
    struct EngagementScore: Identifiable {
        var id = UUID()
        var category: String
        var score: Double // 0.0 - 1.0
        var color: Color
    }
    
    let maxRadius: CGFloat = 150
    
    var body: some View {
        ZStack {
            // Background circles
            ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { scale in
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    .frame(width: maxRadius * 2 * scale)
            }
            
            // Axis lines
            ForEach(0..<scores.count, id: \.self) { index in
                let angle = (2 * .pi / Double(scores.count)) * Double(index) - .pi / 2
                Line(
                    from: .zero,
                    to: CGPoint(
                        x: cos(angle) * maxRadius,
                        y: sin(angle) * maxRadius
                    )
                )
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            }
            
            // Data polygon
            RadarPolygon(scores: scores, maxRadius: maxRadius)
                .fill(Color.blue.opacity(0.2))
            
            RadarPolygon(scores: scores, maxRadius: maxRadius)
                .stroke(Color.blue, lineWidth: 2)
            
            // Data points
            ForEach(scores) { score in
                if let index = scores.firstIndex(where: { $0.id == score.id }) {
                    let angle = (2 * .pi / Double(scores.count)) * Double(index) - .pi / 2
                    let point = CGPoint(
                        x: cos(angle) * maxRadius * score.score,
                        y: sin(angle) * maxRadius * score.score
                    )
                    
                    Circle()
                        .fill(score.color)
                        .frame(width: 8, height: 8)
                        .position(x: point.x + maxRadius, y: point.y + maxRadius)
                }
            }
            
            // Category labels
            ForEach(scores) { score in
                if let index = scores.firstIndex(where: { $0.id == score.id }) {
                    let angle = (2 * .pi / Double(scores.count)) * Double(index) - .pi / 2
                    let labelDistance = maxRadius * 1.15
                    let point = CGPoint(
                        x: cos(angle) * labelDistance,
                        y: sin(angle) * labelDistance
                    )
                    
                    Text(score.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .position(x: point.x + maxRadius, y: point.y + maxRadius)
                        .multilineTextAlignment(.center)
                        .frame(width: 70)
                }
            }
        }
        .frame(width: maxRadius * 2, height: maxRadius * 2)
        .padding(.vertical, 30)
    }
}

struct Line: Shape {
    var from: CGPoint
    var to: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: CGPoint(x: from.x + center.x, y: from.y + center.y))
        path.addLine(to: CGPoint(x: to.x + center.x, y: to.y + center.y))
        return path
    }
}

struct RadarPolygon: Shape {
    let scores: [EngagementRadarChart.EngagementScore]
    let maxRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        for (index, score) in scores.enumerated() {
            let angle = (2 * .pi / Double(scores.count)) * Double(index) - .pi / 2
            let point = CGPoint(
                x: cos(angle) * maxRadius * score.score + center.x,
                y: sin(angle) * maxRadius * score.score + center.y
            )
            
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        path.closeSubpath()
        return path
    }
}

struct EngagementRadarChart_Previews: PreviewProvider {
    static var previews: some View {
        EngagementRadarChart(scores: [
            .init(category: "Participation", score: 0.8, color: .blue),
            .init(category: "Assignment Completion", score: 0.9, color: .green),
            .init(category: "Attendance", score: 0.75, color: .orange),
            .init(category: "Peer Interaction", score: 0.6, color: .purple),
            .init(category: "Critical Thinking", score: 0.85, color: .pink)
        ])
    }
}