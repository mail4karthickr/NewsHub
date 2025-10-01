import SwiftUI

/// Login module providing authentication UI components
public struct Login {
    
    /// Initializes the Login module
    public init() {}
    
    /// Creates a Google login button
    /// - Parameter action: The action to be performed when the button is tapped
    /// - Returns: A SwiftUI view for Google login
    public static func googleLoginButton(action: @escaping () -> Void) -> some View {
        GoogleLoginButton(action: action)
    }
    
    /// Creates a Google brand login button
    /// - Parameter action: The action to be performed when the button is tapped
    /// - Returns: A SwiftUI view for Google brand login
    public static func googleBrandLoginButton(action: @escaping () -> Void) -> some View {
        GoogleBrandLoginButton(action: action)
    }
    
    /// Creates a Google OAuth login button with full authentication flow
    /// - Parameters:
    ///   - onSuccess: Called when sign-in succeeds with GoogleUser
    ///   - onError: Called when sign-in fails with GoogleAuthError
    /// - Returns: A SwiftUI view for Google OAuth login
    public static func googleOAuthLoginButton(
        onSuccess: @escaping (GoogleUser) -> Void,
        onError: @escaping (GoogleAuthError) -> Void
    ) -> some View {
        GoogleOAuthLoginButton(onSuccess: onSuccess, onError: onError)
    }
    
    /// Get the shared GoogleAuthManager instance
    public static var authManager: GoogleAuthManager {
        return GoogleAuthManager.shared
    }
}

/// Public exports for easier importing
@_exported import SwiftUI
