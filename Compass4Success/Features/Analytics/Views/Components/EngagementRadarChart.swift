import SwiftUI
import Foundation

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
            BackgroundCircles(maxRadius: maxRadius)
            AxisLines(scores: scores, maxRadius: maxRadius)
            DataPolygons(scores: scores, maxRadius: maxRadius)
            DataPoints(scores: scores, maxRadius: maxRadius)
            CategoryLabels(scores: scores, maxRadius: maxRadius)
        }
        .frame(width: maxRadius * 2, height: maxRadius * 2)
        .padding(.vertical, 30)
    }
}

// MARK: - Component Views
struct BackgroundCircles: View {
    let maxRadius: CGFloat
    let scaleFactors = [0.25, 0.5, 0.75, 1.0]
    
    var body: some View {
        ForEach(scaleFactors, id: \.self) { scale in
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                .frame(width: maxRadius * 2 * scale)
        }
    }
}

struct AxisLines: View {
    let scores: [EngagementRadarChart.EngagementScore]
    let maxRadius: CGFloat
    
    var body: some View {
        ForEach(0..<scores.count, id: \.self) { index in
            AxisLine(index: index, count: scores.count, maxRadius: maxRadius)
        }
    }
}

struct AxisLine: View {
    let index: Int
    let count: Int
    let maxRadius: CGFloat
    
    var body: some View {
        let angle = calculateAngle(index: index, count: count)
        return Line(
            from: .zero,
            to: CGPoint(
                x: Foundation.cos(angle) * maxRadius,
                y: Foundation.sin(angle) * maxRadius
            )
        )
        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
    }
    
    private func calculateAngle(index: Int, count: Int) -> Double {
        return (2 * .pi / Double(count)) * Double(index) - .pi / 2
    }
}

struct DataPolygons: View {
    let scores: [EngagementRadarChart.EngagementScore]
    let maxRadius: CGFloat
    
    var body: some View {
        RadarPolygon(scores: scores, maxRadius: maxRadius)
            .fill(Color.blue.opacity(0.2))
        
        RadarPolygon(scores: scores, maxRadius: maxRadius)
            .stroke(Color.blue, lineWidth: 2)
    }
}

struct DataPoints: View {
    let scores: [EngagementRadarChart.EngagementScore]
    let maxRadius: CGFloat
    
    var body: some View {
        ForEach(scores) { score in
            if let index = scores.firstIndex(where: { $0.id == score.id }) {
                DataPoint(
                    score: score,
                    index: index,
                    count: scores.count,
                    maxRadius: maxRadius
                )
            }
        }
    }
}

struct DataPoint: View {
    let score: EngagementRadarChart.EngagementScore
    let index: Int
    let count: Int
    let maxRadius: CGFloat
    
    var body: some View {
        let position = calculatePosition()
        
        return Circle()
            .fill(score.color)
            .frame(width: 8, height: 8)
            .position(x: position.x + maxRadius, y: position.y + maxRadius)
    }
    
    private func calculatePosition() -> CGPoint {
        let angle = (2 * .pi / Double(count)) * Double(index) - .pi / 2
        return CGPoint(
            x: Foundation.cos(angle) * maxRadius * score.score,
            y: Foundation.sin(angle) * maxRadius * score.score
        )
    }
}

struct CategoryLabels: View {
    let scores: [EngagementRadarChart.EngagementScore]
    let maxRadius: CGFloat
    
    var body: some View {
        ForEach(scores) { score in
            if let index = scores.firstIndex(where: { $0.id == score.id }) {
                CategoryLabel(
                    category: score.category,
                    index: index,
                    count: scores.count,
                    maxRadius: maxRadius
                )
            }
        }
    }
}

struct CategoryLabel: View {
    let category: String
    let index: Int
    let count: Int
    let maxRadius: CGFloat
    
    var body: some View {
        let position = calculatePosition()
        
        return Text(category)
            .font(.caption)
            .foregroundColor(.secondary)
            .position(x: position.x + maxRadius, y: position.y + maxRadius)
            .multilineTextAlignment(.center)
            .frame(width: 70)
    }
    
    private func calculatePosition() -> CGPoint {
        let angle = (2 * .pi / Double(count)) * Double(index) - .pi / 2
        let labelDistance = maxRadius * 1.15
        return CGPoint(
            x: Foundation.cos(angle) * labelDistance,
            y: Foundation.sin(angle) * labelDistance
        )
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
                x: Foundation.cos(angle) * maxRadius * score.score + center.x,
                y: Foundation.sin(angle) * maxRadius * score.score + center.y
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