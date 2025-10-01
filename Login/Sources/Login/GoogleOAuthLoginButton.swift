import SwiftUI

/// Enhanced Google OAuth login button with authentication integration
public struct GoogleOAuthLoginButton: View {
    @ObservedObject private var authManager = GoogleAuthManager.shared
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    public let onSuccess: (GoogleUser) -> Void
    public let onError: (GoogleAuthError) -> Void
    
    public init(
        onSuccess: @escaping (GoogleUser) -> Void,
        onError: @escaping (GoogleAuthError) -> Void
    ) {
        self.onSuccess = onSuccess
        self.onError = onError
    }
    
    public var body: some View {
        Button {
            performGoogleSignIn()
        } label: {
            HStack(spacing: 12) {
                if authManager.isSigningIn {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                } else {
                    // Google "G" icon
                    GoogleGIcon()
                        .frame(width: 20, height: 20)
                }
                
                Text(authManager.isSigningIn ? "Signing in..." : "Continue with Google")
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
        .disabled(authManager.isSigningIn)
        .buttonStyle(PlainButtonStyle())
        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
        .alert("Sign In Error", isPresented: $showErrorAlert) {
            Button("Try Again") {
                performGoogleSignIn()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func performGoogleSignIn() {
        // Prevent double-tap (debounce)
        guard !authManager.isSigningIn else { return }
        
        authManager.signIn { result in
            switch result {
            case .success(let user):
                onSuccess(user)
            case .failure(let error):
                errorMessage = error.localizedDescription
                showErrorAlert = true
                onError(error)
            }
        }
    }
}

/// Custom Google "G" icon
struct GoogleGIcon: View {
    var body: some View {
        ZStack {
            // Google colors approximation using SF Symbols
            Image(systemName: "g.circle.fill")
                .font(.system(size: 20))
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