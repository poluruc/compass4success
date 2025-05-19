import SwiftUI

struct LoadingOverlay: View {
    var message: String?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                
                if let message = message {
                    Text(message)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemBackground).opacity(0.8))
            )
            .shadow(radius: 10)
        }
    }
} 