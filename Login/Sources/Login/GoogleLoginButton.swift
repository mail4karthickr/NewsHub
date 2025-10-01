import SwiftUI

/// A SwiftUI view that provides a Google login button with icon and styling
public struct GoogleLoginButton: View {
    
    /// Action to be performed when the login button is tapped
    public let action: () -> Void
    
    /// Initializes the Google login button
    /// - Parameter action: The action to be performed when the button is tapped
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 12) {
                // Google logo icon
                Image(systemName: "globe")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
                
                Text("Sign in with Google")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

/// Custom Google login button with Google's brand colors
public struct GoogleBrandLoginButton: View {
    
    /// Action to be performed when the login button is tapped
    public let action: () -> Void
    
    /// Initializes the Google brand login button
    /// - Parameter action: The action to be performed when the button is tapped
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 12) {
                // Custom Google "G" icon
                GoogleIcon()
                    .frame(width: 20, height: 20)
                
                Text("Continue with Google")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
    }
}

/// Custom Google "G" icon view
struct GoogleIcon: View {
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Color.white)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
                )
            
            // Google "G" using SF Symbols as a placeholder
            // In a real implementation, you'd use the actual Google logo
            Image(systemName: "g.circle.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .red, .yellow, .green],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}

// MARK: - Preview Provider
#if DEBUG
struct GoogleLoginButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            GoogleLoginButton {
                print("Google login tapped")
            }
            
            GoogleBrandLoginButton {
                print("Google brand login tapped")
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Google Login Buttons")
    }
}
#endif
