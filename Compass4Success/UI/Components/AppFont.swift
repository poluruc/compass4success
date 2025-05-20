import SwiftUI

struct AppFont: ViewModifier {
    @EnvironmentObject var appSettings: AppSettings
    var size: CGFloat
    var weight: Font.Weight = .regular

    func body(content: Content) -> some View {
        let scaledSize = size * appSettings.fontSize
        let font: Font
        switch appSettings.fontName {
        case "Rounded":
            font = .system(size: scaledSize, weight: weight, design: .rounded)
        case "Serif":
            font = .system(size: scaledSize, weight: weight, design: .serif)
        case "Monospaced":
            font = .system(size: scaledSize, weight: weight, design: .monospaced)
        default:
            font = .system(size: scaledSize, weight: weight, design: .default)
        }
        return content.font(font)
    }
}

extension View {
    func appFont(size: CGFloat, weight: Font.Weight = .regular) -> some View {
        self.modifier(AppFont(size: size, weight: weight))
    }
} 