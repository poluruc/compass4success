import SwiftUI

// Common UI components used across the app
// This helps prevent duplicate view declarations

// Common loading overlay
public struct StandardLoadingOverlay: View {
    public init() {}
    
    public var body: some View {
        ZStack {
            Color(.systemBackground)
                .opacity(0.7)
            
            VStack(spacing: 15) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text("Loading...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// Empty state placeholder
public struct StandardEmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionLabel: String?
    var action: (() -> Void)?
    
    public init(icon: String, title: String, message: String, actionLabel: String? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionLabel = actionLabel
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let actionLabel = actionLabel, let action = action {
                Button(action: action) {
                    Text(actionLabel)
                        .fontWeight(.semibold)
                }
                .buttonStyle(CompatibleBorderedButtonStyle())
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Reusable section header
public struct StandardSectionHeader: View {
    let title: String
    var subtitle: String?
    
    public init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Feedback banner
public struct StandardFeedbackView: View {
    public enum FeedbackType {
        case success, error, warning, info
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "exclamationmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .warning: return .orange
            case .info: return .blue
            }
        }
    }
    
    let message: String
    let type: FeedbackType
    
    public init(message: String, type: FeedbackType) {
        self.message = message
        self.type = type
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)
            
            Text(message)
                .font(.subheadline)
            
            Spacer()
        }
        .padding()
        .background(type.color.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
