import SwiftUI
import Foundation

// Color extensions for compatibility with older macOS versions
extension Color {
    static var compatibleTeal: Color {
        #if os(macOS)
            if #available(macOS 13.0, *) {
                return Color.teal
            } else {
                return Color(NSColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 1.0))
            }
        #else
            return Color.teal
        #endif
    }
    
    static var compatibleIndigo: Color {
        #if os(macOS)
            if #available(macOS 13.0, *) {
                return Color.indigo
            } else {
                return Color(NSColor(red: 0.3, green: 0.0, blue: 0.5, alpha: 1.0))
            }
        #else
            return Color.indigo
        #endif
    }
    
    static var compatibleMint: Color {
        #if os(macOS)
            if #available(macOS 13.0, *) {
                return Color.mint
            } else {
                return Color(NSColor(red: 0.0, green: 0.7, blue: 0.6, alpha: 1.0))
            }
        #else
            return Color.mint
        #endif
    }
    
    static var compatibleCyan: Color {
        #if os(macOS)
            if #available(macOS 13.0, *) {
                return Color.cyan
            } else {
                return Color(NSColor(red: 0.0, green: 0.8, blue: 0.9, alpha: 1.0))
            }
        #else
            return Color.cyan
        #endif
    }
}

// Utility for working with colors throughout the application
struct ColorHelper {
    // App theme colors
    struct AppColors {
        static let primary = Color("PrimaryColor", bundle: .main)
        static let secondary = Color("SecondaryColor", bundle: .main)
        static let accent = Color("AccentColor", bundle: .main)
        static let background = Color("BackgroundColor", bundle: .main)
        static let text = Color("TextColor", bundle: .main)
        static let error = Color("ErrorColor", bundle: .main)
        static let success = Color("SuccessColor", bundle: .main)
        static let warning = Color("WarningColor", bundle: .main)
        static let info = Color("InfoColor", bundle: .main)
    }
    
    // Grade colors based on performance
    struct GradeColors {
        static func forPercentage(_ percentage: Double) -> Color {
            switch percentage {
            case 90...100:
                return Color.green
            case 80..<90:
                return Color.blue
            case 70..<80:
                return Color.yellow
            case 60..<70:
                return Color.orange
            default:
                return Color.red
            }
        }
        
        static func forLetterGrade(_ letter: String) -> Color {
            switch letter {
            case "A+", "A", "A-":
                return Color.green
            case "B+", "B", "B-":
                return Color.blue
            case "C+", "C", "C-":
                return Color.yellow
            case "D+", "D", "D-":
                return Color.orange
            default:
                return Color.red
            }
        }
        
        static func forAchievementLevel(_ level: Int) -> Color {
            switch level {
            case 4:
                return Color.green
            case 3:
                return Color.blue
            case 2:
                return Color.orange
            case 1:
                return Color.red
            default:
                return Color.gray
            }
        }
    }
    
    // Colors for analytics charts
    struct ChartColors {
        static let palette: [Color] = [
            .blue,
            .green,
            .orange,
            .purple,
            .red,
            .yellow,
            .pink,
            .mint,
            .indigo,
            .teal
        ]
        
        static func color(for index: Int) -> Color {
            return palette[index % palette.count]
        }
        
        static let positiveChange = Color.green
        static let negativeChange = Color.red
        static let neutral = Color.gray
        static let target = Color.purple
        
        // Gradient arrays for charts
        static let blueGradient = Gradient(colors: [.blue.opacity(0.3), .blue])
        static let greenGradient = Gradient(colors: [.green.opacity(0.3), .green])
        static let orangeGradient = Gradient(colors: [.orange.opacity(0.3), .orange])
        
        // Generate a gradient for a specific color
        static func gradientFor(color: Color) -> Gradient {
            return Gradient(colors: [color.opacity(0.3), color])
        }
    }
    
    // Subject-specific colors
    struct SubjectColors {
        static let math = Color.blue
        static let science = Color.green
        static let english = Color.purple
        static let history = Color.brown
        static let art = Color.pink
        static let music = Color.indigo
        static let pe = Color.orange
        static let language = Color.compatibleTeal
        
        static func color(for subject: String) -> Color {
            switch subject.lowercased() {
            case _ where subject.lowercased().contains("math"):
                return math
            case _ where subject.lowercased().contains("science"):
                return science
            case _ where subject.lowercased().contains("english"):
                return english
            case _ where subject.lowercased().contains("history"):
                return history
            case _ where subject.lowercased().contains("art"):
                return art
            case _ where subject.lowercased().contains("music"):
                return music
            case _ where subject.lowercased().contains("phys") || subject.lowercased().contains("pe"):
                return pe
            case _ where subject.lowercased().contains("language") || subject.lowercased().contains("spanish") || subject.lowercased().contains("french"):
                return language
            default:
                return .gray
            }
        }
    }
    
    // Status-related colors
    struct StatusColors {
        static let active = Color.green
        static let inactive = Color.gray
        static let pending = Color.yellow
        static let warning = Color.orange
        static let error = Color.red
        static let late = Color.red
        static let onTime = Color.green
        static let excused = Color.blue
    }
    
    // Accessibility color schemes
    struct AccessibilityColors {
        // High contrast color scheme
        static let highContrastBackground = Color.black
        static let highContrastForeground = Color.white
        static let highContrastAccent = Color.yellow
        
        // Color blind-friendly palette (based on ColorBrewer)
        static let colorBlindSafe: [Color] = [
            Color(red: 0.9, green: 0.1, blue: 0.1),    // Red
            Color(red: 0.2, green: 0.6, blue: 0.8),    // Blue
            Color(red: 0.3, green: 0.7, blue: 0.3),    // Green
            Color(red: 0.6, green: 0.6, blue: 0.6),    // Gray
            Color(red: 0.8, green: 0.5, blue: 0.1),    // Orange
            Color(red: 0.5, green: 0.3, blue: 0.7),    // Purple
            Color(red: 0.8, green: 0.8, blue: 0.1)     // Yellow
        ]
    }
    
    // Generate color from string (useful for consistent color generation)
    static func colorFromString(_ string: String) -> Color {
        let hash = string.hash
        let r = Double(abs(hash) % 255) / 255.0
        let g = Double(abs(hash / 255) % 255) / 255.0
        let b = Double(abs(hash / 65025) % 255) / 255.0
        
        return Color(red: r, green: g, blue: b)
    }
    
    // Generate a color for user avatar based on initials
    static func avatarColor(for initials: String) -> Color {
        let colors: [Color] = [
            .blue, .green, .orange, .purple, .pink, .compatibleIndigo, .compatibleTeal, .compatibleMint, .compatibleCyan, .yellow
        ]
        
        // Use the hash of the initials to pick a color
        let hash = initials.hash
        let index = abs(hash) % colors.count
        
        return colors[index]
    }
    
    // Create a linear gradient for charts
    static func linearGradient(for color: Color) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [color.opacity(0.5), color]),
            startPoint: .bottom,
            endPoint: .top
        )
    }
}