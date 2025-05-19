import SwiftUI
import Foundation

// Models used by the Dashboard feature

// Quick statistic card model
struct QuickStat: Identifiable {
    var id = UUID()
    var title: String
    var value: String
    var description: String
    var icon: String
    var color: Color
    
    init(title: String, value: String, description: String, icon: String, color: Color) {
        self.title = title
        self.value = value
        self.description = description
        self.icon = icon
        self.color = color
    }
}

// Activity item for recent activity feed
struct ActivityItem: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var timestamp: Date
    var icon: String
    var color: Color
    var timeAgo: String {
        // Format relative time
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    init(title: String, description: String, timestamp: Date, icon: String, color: Color) {
        self.title = title
        self.description = description
        self.timestamp = timestamp
        self.icon = icon
        self.color = color
    }
}

// Announcement model
struct Announcement: Identifiable {
    var id = UUID()
    var title: String
    var content: String
    var date: Date
    var author: String
    var priority: AnnouncementPriority = .normal
    
    enum AnnouncementPriority: String, CaseIterable {
        case low = "Low"
        case normal = "Normal"
        case high = "High"
        case urgent = "Urgent"
        
        var color: Color {
            switch self {
            case .low:
                return .gray
            case .normal:
                return .blue
            case .high:
                return .orange
            case .urgent:
                return .red
            }
        }
    }
    
    init(title: String, content: String, date: Date, author: String, priority: AnnouncementPriority = .normal) {
        self.title = title
        self.content = content
        self.date = date
        self.author = author
        self.priority = priority
    }
}

// Create an alias for StandardFeedbackView.FeedbackType to resolve the confusion with FeedbackView
typealias FeedbackType = StandardFeedbackView.FeedbackType
extension FeedbackView {
    typealias FeedbackType = StandardFeedbackView.FeedbackType
}

// Define the FeedbackView as a wrapper around StandardFeedbackView for backward compatibility
struct FeedbackView: View {
    let message: String
    let type: StandardFeedbackView.FeedbackType
    
    var body: some View {
        StandardFeedbackView(message: message, type: type)
    }
} 