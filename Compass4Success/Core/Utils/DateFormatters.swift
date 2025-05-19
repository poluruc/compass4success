import Foundation

public enum DateFormatterProvider {
    public static let standard: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    public static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    public static let longDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    public static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    public static let dateAndTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    public static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}

extension Date {
    // Formatted date string helpers
    
    public var formattedStandardDate: String {
        return DateFormatterProvider.standard.string(from: self)
    }
    
    public var formattedShortDate: String {
        return DateFormatterProvider.shortDate.string(from: self)
    }
    
    public var formattedLongDate: String {
        return DateFormatterProvider.longDate.string(from: self)
    }
    
    public var formattedTime: String {
        return DateFormatterProvider.time.string(from: self)
    }
    
    public var formattedDateAndTime: String {
        return DateFormatterProvider.dateAndTime.string(from: self)
    }
    
    // Date calculations
    
    public var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    public var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    public var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }
    
    public var endOfWeek: Date {
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfWeek)!
    }
    
    public var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    public var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    public var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    public var isInFuture: Bool {
        return self > Date()
    }
    
    public var isInPast: Bool {
        return self < Date()
    }
}
