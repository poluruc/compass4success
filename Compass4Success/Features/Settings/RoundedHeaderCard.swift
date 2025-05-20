import SwiftUI

struct RoundedHeaderCard: View {
    let title: String
    let subtitle: String?
    let icon: String?

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Text(title)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding()
        }
        .frame(height: 110)
        .padding(.horizontal)
        .padding(.top, 8)
    }
} 