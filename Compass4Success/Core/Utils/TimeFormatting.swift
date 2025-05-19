import Foundation

// Utility for time and date formatting throughout the application
struct TimeFormatting {
    // Date formatters
    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    private static let mediumDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    private static let longDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private static let shortTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    private static let mediumTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }()
    
    private static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    private static let dayMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    private static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    private static let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    private static let customFormatter: DateFormatter = {
        let formatter = DateFormatter()
        return formatter
    }()
    
    // Date formatting
    static func formatShortDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        return shortDateFormatter.string(from: date)
    }
    
    static func formatMediumDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        return mediumDateFormatter.string(from: date)
    }
    
    static func formatLongDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        return longDateFormatter.string(from: date)
    }
    
    static func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        return shortTimeFormatter.string(from: date)
    }
    
    static func formatDateTime(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        return dateTimeFormatter.string(from: date)
    }
    
    static func formatISO8601(_ date: Date?) -> String {
        guard let date = date else { return "" }
        return iso8601Formatter.string(from: date)
    }
    
    static func formatMonthDay(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        return dayMonthFormatter.string(from: date)
    }
    
    static func formatMonthYear(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        return monthYearFormatter.string(from: date)
    }
    
    static func formatDayOfWeek(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        return dayOfWeekFormatter.string(from: date)
    }
    
    static func formatCustom(_ date: Date?, format: String) -> String {
        guard let date = date else { return "N/A" }
        customFormatter.dateFormat = format
        return customFormatter.string(from: date)
    }
    
    // Date parsing
    static func parseISO8601(_ string: String) -> Date? {
        return iso8601Formatter.date(from: string)
    }
    
    static func parseCustom(_ string: String, format: String) -> Date? {
        customFormatter.dateFormat = format
        return customFormatter.date(from: string)
    }
    
    // Relative time formatting
    static func timeAgo(from date: Date?) -> String {
        guard let date = date else { return "N/A" }
        
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: now)
        
        if let years = components.year, years > 0 {
            return years == 1 ? "1 year ago" : "\(years) years ago"
        }
        
        if let months = components.month, months > 0 {
            return months == 1 ? "1 month ago" : "\(months) months ago"
        }
        
        if let days = components.day, days > 0 {
            return days == 1 ? "Yesterday" : "\(days) days ago"
        }
        
        if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        }
        
        if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
        }
        
        return "Just now"
    }
    
    // School year and term helpers
    static func currentSchoolYear() -> String {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        
        // Assume school year starts in August/September
        if month >= 8 {
            return "\(year)-\(year + 1)"
        } else {
            return "\(year - 1)-\(year)"
        }
    }
    
    static func currentTerm() -> String {
        let calendar = Calendar.current
        let now = Date()
        let month = calendar.component(.month, from: now)
        
        // Simple term determination
        switch month {
        case 8...12:
            return "Fall"
        case 1...5:
            return "Spring"
        default:
            return "Summer"
        }
    }
    
    // Due date helpers
    static func dueStatus(for date: Date?) -> DueStatus {
        guard let date = date else { return .unknown }
        
        let now = Date()
        let calendar = Calendar.current
        
        if date < now {
            let components = calendar.dateComponents([.day], from: date, to: now)
            if let days = components.day, days <= 1 {
                return .overdue
            } else {
                return .past
            }
        } else {
            let components = calendar.dateComponents([.day], from: now, to: date)
            if let days = components.day {
                if days == 0 {
                    return .today
                } else if days == 1 {
                    return .tomorrow
                } else if days <= 7 {
                    return .thisWeek
                } else {
                    return .future
                }
            }
        }
        
        return .unknown
    }
    
    static func dueDateText(for date: Date?) -> String {
        guard let date = date else { return "No due date" }
        
        let status = dueStatus(for: date)
        
        switch status {
        case .today:
            return "Due today"
        case .tomorrow:
            return "Due tomorrow"
        case .thisWeek:
            return "Due this week (\(formatShortDate(date)))"
        case .future:
            return "Due \(formatMediumDate(date))"
        case .overdue:
            return "Overdue (due \(formatShortDate(date)))"
        case .past:
            return "Was due \(formatShortDate(date))"
        case .unknown:
            return "Due \(formatShortDate(date))"
        }
    }
    
    // Academic year utilities
    static func academicYearForDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        // Assume academic year starts in August
        if month >= 8 {
            return "\(year)-\(year + 1)"
        } else {
            return "\(year - 1)-\(year)"
        }
    }
    
    static func currentAcademicYear() -> String {
        return academicYearForDate(Date())
    }
    
    // Date range formatting
    static func formatDateRange(from: Date?, to: Date?) -> String {
        guard let from = from else { return "N/A" }
        
        if let to = to {
            // Check if dates are in the same year
            let calendar = Calendar.current
            let fromYear = calendar.component(.year, from: from)
            let toYear = calendar.component(.year, from: to)
            
            if fromYear == toYear {
                // Same year - show month and day for both
                let fromString = formatCustom(from, format: "MMM d")
                let toString = formatCustom(to, format: "MMM d, yyyy")
                return "\(fromString) - \(toString)"
            } else {
                // Different years - show full dates
                return "\(formatMediumDate(from)) - \(formatMediumDate(to))"
            }
        } else {
            return "From \(formatMediumDate(from))"
        }
    }
}

// Due date status enum
enum DueStatus {
    case today
    case tomorrow
    case thisWeek
    case future
    case overdue
    case past
    case unknown
    
    var color: String {
        switch self {
        case .today:
            return "red"
        case .tomorrow:
            return "orange"
        case .thisWeek:
            return "yellow"
        case .future:
            return "blue"
        case .overdue:
            return "red"
        case .past:
            return "gray"
        case .unknown:
            return "gray"
        }
    }
}