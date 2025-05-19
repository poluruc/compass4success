import SwiftUI
import Charts
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// Collection of special-purpose chart components that don't fit into the other categories

@available(macOS 13.0, iOS 16.0, *)
struct SpecialtyCharts {
    // Progress gauge chart
    struct CircularProgressGauge: View {
        var value: Double // 0.0 - 1.0
        var label: String
        var color: Color = .blue
        var showPercentage: Bool = true
        var size: CGFloat = 120
        
        var body: some View {
            VStack {
                ZStack {
                    Circle()
                        .stroke(
                            color.opacity(0.2),
                            lineWidth: 10
                        )
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(value))
                        .stroke(
                            color,
                            style: StrokeStyle(
                                lineWidth: 10,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: value)
                    
                    if showPercentage {
                        Text("\(Int(value * 100))%")
                            .font(.system(size: size / 5).bold())
                    }
                }
                .frame(width: size, height: size)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // Comparison bar chart (side by side)
    @available(macOS 13.0, iOS 16.0, *)
    struct ComparisonBarChart: View {
        var categories: [String]
        var dataset1: [Double]
        var dataset2: [Double]
        var dataset1Label: String
        var dataset2Label: String
        var dataset1Color: Color = .blue
        var dataset2Color: Color = .green
        var height: CGFloat = 250
        
        @available(macOS 13.0, iOS 16.0, *)
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Chart {
                    ForEach(Array(categories.enumerated()), id: \.element) { index, category in
                        if index < dataset1.count {
                            BarMark(
                                x: .value("Category", "\(category) - \(dataset1Label)"),
                                y: .value("Value", dataset1[index])
                            )
                            .foregroundStyle(dataset1Color)
                        }
                        
                        if index < dataset2.count {
                            BarMark(
                                x: .value("Category", "\(category) - \(dataset2Label)"),
                                y: .value("Value", dataset2[index])
                            )
                            .foregroundStyle(dataset2Color)
                        }
                    }
                }
                .frame(height: height)
                
                // Legend
                HStack(spacing: 20) {
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(dataset1Color)
                            .frame(width: 12, height: 12)
                        Text(dataset1Label)
                            .font(.caption)
                    }
                    
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(dataset2Color)
                            .frame(width: 12, height: 12)
                        Text(dataset2Label)
                            .font(.caption)
                    }
                }
            }
        }
    }
    
    // Attendance heatmap (simplified version)
    struct AttendanceHeatMap: View {
        var data: [AttendanceRecord]
        var numWeeks: Int = 12
        var cellSize: CGFloat = 20
        
        struct AttendanceRecord: Identifiable {
            var id = UUID()
            var date: Date
            var status: AttendanceStatus
            
            enum AttendanceStatus: String, CaseIterable {
                case present = "Present"
                case late = "Late"
                case excused = "Excused"
                case unexcused = "Unexcused"
                
                var color: Color {
                    switch self {
                    case .present: return .green
                    case .late: return .yellow
                    case .excused: return .blue
                    case .unexcused: return .red
                    }
                }
            }
        }
        
        // Generate days of the week
        private let daysOfWeek = ["M", "T", "W", "T", "F"]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                // Day headers
                HStack(spacing: 4) {
                    Text("")
                        .frame(width: 30)
                    
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: cellSize)
                    }
                }
                
                // Weeks and days grid
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(0..<numWeeks, id: \.self) { week in
                            HStack(spacing: 4) {
                                Text("W\(week+1)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 30)
                                
                                ForEach(0..<5, id: \.self) { day in
                                    let cellDate = getCellDate(week: week, day: day)
                                    let record = getAttendanceRecord(for: cellDate)
                                    
                                    Rectangle()
                                        .fill(record?.status.color ?? Color.gray.opacity(0.1))
                                        .frame(width: cellSize, height: cellSize)
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Legend
                HStack(spacing: 16) {
                    ForEach(AttendanceRecord.AttendanceStatus.allCases, id: \.self) { status in
                        HStack(spacing: 4) {
                            Rectangle()
                                .fill(status.color)
                                .frame(width: 12, height: 12)
                                .cornerRadius(2)
                            
                            Text(status.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        
        private func getCellDate(week: Int, day: Int) -> Date {
            // Simple implementation - a real app would use actual calendar calculations
            let calendar = Calendar.current
            let today = Date()
            let startOfSemester = calendar.date(byAdding: .day, value: -(numWeeks * 7), to: today)!
            let daysToAdd = week * 7 + day
            return calendar.date(byAdding: .day, value: daysToAdd, to: startOfSemester)!
        }
        
        private func getAttendanceRecord(for date: Date) -> AttendanceRecord? {
            return data.first(where: { isSameDay($0.date, date) })
        }
        
        private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
            let calendar = Calendar.current
            return calendar.isDate(date1, inSameDayAs: date2)
        }
    }
    
    // Achievement progress meter
    struct AchievementProgressMeter: View {
        var achievementLevels: [AchievementLevel]
        var currentValue: Double
        var targetValue: Double? = nil
        var height: CGFloat = 40
        
        struct AchievementLevel: Identifiable {
            var id = UUID()
            var label: String
            var threshold: Double
            var color: Color
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .leading) {
                    // Background track
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: height)
                        .cornerRadius(8)
                    
                    // Achievement level segments
                    HStack(spacing: 0) {
                        ForEach(achievementLevels.sorted(by: { $0.threshold < $1.threshold })) { level in
                            Rectangle()
                                .fill(level.color.opacity(0.3))
                                .frame(width: getWidthForThreshold(level.threshold), height: height)
                        }
                    }
                    .cornerRadius(8)
                    
                    // Current value indicator
                    if currentValue > 0 {
                        Rectangle()
                            .fill(getCurrentLevelColor())
                            .frame(width: min(getWidthForValue(currentValue), getMaxScreenWidth() - 40), height: height)
                            .cornerRadius(8)
                    }
                    
                    // Target value indicator (if present)
                    if let target = targetValue {
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 4, height: height + 10)
                            .position(x: getWidthForValue(target), y: height / 2)
                    }
                    
                    // Level labels
                    HStack(spacing: 0) {
                        ForEach(achievementLevels.sorted(by: { $0.threshold < $1.threshold })) { level in
                            Text(level.label)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .frame(width: getWidthForThreshold(level.threshold))
                        }
                    }
                }
                
                // Value indicator below the meter
                Text("\(Int(currentValue)) / \(Int(getMaxThreshold()))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        
        private func getMaxThreshold() -> Double {
            achievementLevels.map { $0.threshold }.max() ?? 100
        }
        
        private func getMaxScreenWidth() -> CGFloat {
            #if os(iOS)
            return UIScreen.main.bounds.width
            #elseif os(macOS)
            return NSScreen.main?.frame.width ?? 1000
            #else
            return 1000 // Default fallback
            #endif
        }
        
        private func getWidthForThreshold(_ threshold: Double) -> CGFloat {
            let maxThreshold = getMaxThreshold()
            let maxWidth = getMaxScreenWidth() - 40 // accounting for padding
            return CGFloat(threshold / maxThreshold) * maxWidth
        }
        
        private func getWidthForValue(_ value: Double) -> CGFloat {
            let maxThreshold = getMaxThreshold()
            let maxWidth = getMaxScreenWidth() - 40 // accounting for padding
            return CGFloat(min(value, maxThreshold) / maxThreshold) * maxWidth
        }
        
        private func getCurrentLevelColor() -> Color {
            let sortedLevels = achievementLevels.sorted(by: { $0.threshold < $1.threshold })
            for i in (0..<sortedLevels.count).reversed() {
                if currentValue >= sortedLevels[i].threshold {
                    return sortedLevels[i].color
                }
            }
            return .gray
        }
    }
}

@available(macOS 13.0, iOS 16.0, *)
struct SpecialtyCharts_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 30) {
                SpecialtyCharts.CircularProgressGauge(
                    value: 0.75,
                    label: "Assignments",
                    color: .green
                )
                
                SpecialtyCharts.ComparisonBarChart(
                    categories: ["Math", "Science", "English"],
                    dataset1: [83, 76, 91],
                    dataset2: [79, 81, 85],
                    dataset1Label: "Current",
                    dataset2Label: "Previous"
                )
                
                // Mock attendance data for 3 weeks
                SpecialtyCharts.AttendanceHeatMap(
                    data: generateMockAttendance(),
                    numWeeks: 4
                )
                
                SpecialtyCharts.AchievementProgressMeter(
                    achievementLevels: [
                        .init(label: "Basic", threshold: 0, color: .red),
                        .init(label: "Proficient", threshold: 30, color: .orange),
                        .init(label: "Advanced", threshold: 60, color: .blue),
                        .init(label: "Mastery", threshold: 85, color: .green)
                    ],
                    currentValue: 72,
                    targetValue: 85
                )
            }
            .padding()
        }
    }
    
    static func generateMockAttendance() -> [SpecialtyCharts.AttendanceHeatMap.AttendanceRecord] {
        var records: [SpecialtyCharts.AttendanceHeatMap.AttendanceRecord] = []
        let calendar = Calendar.current
        let today = Date()
        let startOfSemester = calendar.date(byAdding: .day, value: -28, to: today)!
        
        let statuses: [SpecialtyCharts.AttendanceHeatMap.AttendanceRecord.AttendanceStatus] = [
            .present, .present, .present, .present, .present, .present, .present, .present,
            .present, .present, .late, .present, .present, .excused, .present, .present,
            .unexcused, .present, .present
        ]
        
        for i in 0..<20 {
            if i < statuses.count {
                let date = calendar.date(byAdding: .day, value: i, to: startOfSemester)!
                records.append(SpecialtyCharts.AttendanceHeatMap.AttendanceRecord(
                    date: date,
                    status: statuses[i]
                ))
            }
        }
        
        return records
    }
}