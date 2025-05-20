import SwiftUI

class AppSettings: ObservableObject {
    @Published var colorScheme: ColorScheme? = nil // .light, .dark, or nil (system)
    @Published var accentColor: Color = .blue {
        didSet {
            secondaryColor = AppSettings.secondaryColor(for: accentColor)
        }
    }
    @Published private(set) var secondaryColor: Color = AppSettings.secondaryColor(for: .blue)
    
    static func secondaryColor(for primary: Color) -> Color {
        switch primary {
        case .blue: return Color.cyan
        case .red: return Color.orange
        case .green: return Color.mint
        case .orange: return Color.yellow
        case .purple: return Color.pink
        case .pink: return Color.purple.opacity(0.7)
        default: return Color.gray.opacity(0.5)
        }
    }
} 