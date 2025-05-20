import Foundation
import SwiftUI

// Data models for analytics
struct ChartDataPoint: Identifiable {
    var id = UUID()
    var label: String
    var value: Double
    
    init(label: String, value: Double) {
        self.label = label
        self.value = value
    }
}

struct TimeSeriesDataPoint: Identifiable {
    var id = UUID()
    var label: String // Series label (e.g. "Class Average")
    var date: Date
    var value: Double
    var color: Color = .blue
    
    init(label: String, date: Date, value: Double) {
        self.label = label
        self.date = date
        self.value = value
        // The color is set via the default parameter
    }
}

struct ScatterPlotDataPoint: Identifiable {
    var id = UUID()
    var label: String // Student name or ID
    var x: Double // X axis value
    var y: Double // Y axis value
    
    init(label: String, x: Double, y: Double) {
        self.label = label
        self.x = x
        self.y = y
    }
}

struct AnalyticsInsight: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var icon: String
    var color: Color
    
    init(title: String, description: String, icon: String, color: Color) {
        self.title = title
        self.description = description
        self.icon = icon
        self.color = color
    }
}
