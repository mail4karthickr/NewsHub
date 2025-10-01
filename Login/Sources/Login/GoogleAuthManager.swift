import Foundation
import SwiftUI
import GoogleSignIn

#if canImport(UIKit)
import UIKit
#endif

// MARK: - GoogleUser data model
public struct GoogleUser: Codable {
    public let id: String
    public let displayName: String
    public let email: String
    public let photoURL: URL?
    
    public init(id: String, displayName: String, email: String, photoURL: URL? = nil) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.photoURL = photoURL
    }
}

// MARK: - GoogleAuth Error
public enum GoogleAuthError: Error {
    case signInCancelled
    case signInFailed(Error)
    case networkError
    case noNetwork
    case invalidCredentials
    case configurationError
    case unknown
    
    public var localizedDescription: String {
        switch self {
        case .signInCancelled:
            return "Sign-in was cancelled"
        case .signInFailed(let error):
            return "Sign-in failed: \(error.localizedDescription)"
        case .networkError:
            return "Network error occurred during sign-in"
        case .noNetwork:
            return "No network connection. Please check your internet and try again"
        case .invalidCredentials:
            return "Invalid sign-in credentials"
        case .configurationError:
            return "Google Sign-In is not properly configured. Please contact the developer."
        case .unknown:
            return "Unknown error occurred during sign-in"
        }
    }
}

// MARK: - GoogleAuthManager
public class GoogleAuthManager: ObservableObject {
    @Published public private(set) var isSigningIn = false
    @Published public var currentUser: GoogleUser?
    
    // UserDefaults keys for session persistence
    private let userDefaultsKey = "com.newshub.googleUser"
    private let accessTokenKey = "com.newshub.googleAccessToken"
    private let tokenExpiryDateKey = "com.newshub.googleTokenExpiryDate"
    
    public static let shared = GoogleAuthManager()
    
    private init() {
        // Load cached session on init
        loadStoredSession()
    }
    
    // MARK: - Session Management
    
    /// Check if user is logged in with valid session
    public var isLoggedIn: Bool {
        currentUser != nil && hasValidToken
    }
    
    /// Check if the access token is valid and not expired
    private var hasValidToken: Bool {
        if let tokenExpiryDate = UserDefaults.standard.object(forKey: tokenExpiryDateKey) as? Date {
            // Add some buffer (5 minutes) to handle refresh before expiry
            return tokenExpiryDate.timeIntervalSinceNow > 300
        }
        return false
    }
    
    /// Load stored user session from UserDefaults
    private func loadStoredSession() {
        guard let userData = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        
        do {
            currentUser = try JSONDecoder().decode(GoogleUser.self, from: userData)
            print("✅ Restored user session for: \(currentUser?.displayName ?? "unknown")")
        } catch {
            print("⚠️ Failed to decode stored user: \(error)")
            // Clear potentially corrupted session data
            clearSession()
        }
    }
    
    /// Store current user session to UserDefaults
    private func storeSession(user: GoogleUser, token: String, expiresIn: TimeInterval) {
        do {
            let userData = try JSONEncoder().encode(user)
            let expiryDate = Date().addingTimeInterval(expiresIn)
            
            UserDefaults.standard.set(userData, forKey: userDefaultsKey)
            UserDefaults.standard.set(token, forKey: accessTokenKey)
            UserDefaults.standard.set(expiryDate, forKey: tokenExpiryDateKey)
        } catch {
            print("⚠️ Failed to encode user: \(error)")
        }
    }
    
    /// Clear the stored session
    private func clearSession() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: tokenExpiryDateKey)
        currentUser = nil
    }
    
    // MARK: - Authentication Methods
    
    /// Sign in with Google account
    /// - Parameters:
    ///   - completion: Callback that returns result with GoogleUser on success or GoogleAuthError on failure
    public func signIn(completion: @escaping (Result<GoogleUser, GoogleAuthError>) -> Void) {
        guard !isSigningIn else { return }
        
        isSigningIn = true
        
        // Check if Google Sign-In is configured with valid credentials
        guard let configuration = GIDSignIn.sharedInstance.configuration else {
            isSigningIn = false
            print("❌ Google Sign-In configuration is nil. SDK not properly initialized.")
            completion(.failure(.configurationError))
            return
        }
        
        guard !configuration.clientID.isEmpty,
              !configuration.clientID.contains("YOUR_") else {
            isSigningIn = false
            print("❌ Google Sign-In not properly configured. Client ID is missing or contains placeholder values.")
            print("   Current client ID: \(configuration.clientID.prefix(20))...")
            completion(.failure(.configurationError))
            return
        }
        
        print("🔍 Starting Google Sign-In with client ID: \(configuration.clientID.prefix(20))...")
        
        #if canImport(UIKit)
        // Get the presenting view controller for iOS
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let presentingViewController = windowScene.windows.first?.rootViewController else {
            isSigningIn = false
            print("❌ Failed to get presenting view controller")
            completion(.failure(.unknown))
            return
        }
        
        print("🔍 Found presenting view controller: \(type(of: presentingViewController))")
        
        // Perform Google Sign-In with exception handling
        do {
            GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ Google Sign-In error: \(error)")
                        self?.handleSignInResult(.failure(error), completion: completion)
                    } else if let result = result {
                        print("✅ Google Sign-In successful")
                        self?.handleSignInResult(.success(result), completion: completion)
                    } else {
                        print("❌ Google Sign-In returned neither result nor error")
                        self?.handleSignInResult(.failure(NSError(domain: "GoogleAuth", code: -1)), completion: completion)
                    }
                }
            }
        } catch {
            print("❌ Exception thrown during Google Sign-In: \(error)")
            isSigningIn = false
            completion(.failure(.unknown))
        }
        #else
        // macOS implementation would go here
        isSigningIn = false
        completion(.failure(.unknown))
        #endif
    }
    
    /// Handle the sign-in result from Google Sign-In SDK
    private func handleSignInResult(_ result: Result<GIDSignInResult, Error>, completion: @escaping (Result<GoogleUser, GoogleAuthError>) -> Void) {
        DispatchQueue.main.async { [weak self] in
            self?.isSigningIn = false
            
            switch result {
            case .success(let gidSignInResult):
                let gidUser = gidSignInResult.user
                let profile = gidUser.profile
                
                let user = GoogleUser(
                    id: gidUser.userID ?? "",
                    displayName: profile?.name ?? "",
                    email: profile?.email ?? "",
                    photoURL: profile?.imageURL(withDimension: 200)
                )
                
                // Get access token
                gidUser.refreshTokensIfNeeded { [weak self] refreshedUser, error in
                    DispatchQueue.main.async {
                        if let refreshedUser = refreshedUser {
                            let accessToken = refreshedUser.accessToken.tokenString
                            let expiresIn = refreshedUser.accessToken.expirationDate?.timeIntervalSinceNow ?? 3600
                            
                            // Store session data
                            self?.currentUser = user
                            self?.storeSession(
                                user: user,
                                token: accessToken,
                                expiresIn: expiresIn
                            )
                            
                            completion(.success(user))
                        } else {
                            completion(.failure(.signInFailed(error ?? NSError(domain: "GoogleAuth", code: -1))))
                        }
                    }
                }
                
            case .failure(let error):
                if let gidError = error as? GIDSignInError {
                    switch gidError.code {
                    case .canceled:
                        completion(.failure(.signInCancelled))
                    case .hasNoAuthInKeychain:
                        completion(.failure(.invalidCredentials))
                    default:
                        completion(.failure(.signInFailed(error)))
                    }
                } else {
                    completion(.failure(.signInFailed(error)))
                }
            }
        }
    }
    
    /// Sign out the current user
    public func signOut() {
        GIDSignIn.sharedInstance.signOut()
        clearSession()
    }
    
    /// Refresh the access token if needed
    /// - Parameter completion: Callback with success or failure
    public func refreshTokenIfNeeded(completion: @escaping (Bool) -> Void) {
        guard let user = currentUser else {
            completion(false)
            return
        }
        
        if hasValidToken {
            completion(true)
            return
        }
        
        // Try to restore previous sign-in and refresh tokens
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] gidUser, error in
            DispatchQueue.main.async {
                if let gidUser = gidUser {
                    gidUser.refreshTokensIfNeeded { [weak self] refreshedUser, refreshError in
                        DispatchQueue.main.async {
                            if let refreshedUser = refreshedUser {
                                let accessToken = refreshedUser.accessToken.tokenString
                                let expiresIn = refreshedUser.accessToken.expirationDate?.timeIntervalSinceNow ?? 3600
                                
                                self?.storeSession(user: user, token: accessToken, expiresIn: expiresIn)
                                completion(true)
                            } else {
                                self?.clearSession()
                                completion(false)
                            }
                        }
                    }
                } else {
                    self?.clearSession()
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Check if network is available (simplified for demo)
    private func isNetworkAvailable() -> Bool {
        // In a real app, implement actual network reachability check
        return true
    }
    
    // MARK: - Configuration
    
    /// Configure Google Sign-In with client ID
    /// - Parameter clientID: The Google OAuth client ID
    public func configure(clientID: String) {
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        print("✅ Google Sign-In configured with client ID: \(clientID.prefix(10))...")
    }
    
    /// Try to restore previous sign-in on app launch
    public func restorePreviousSignIn(completion: @escaping (Bool) -> Void) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] gidUser, error in
            DispatchQueue.main.async {
                if let gidUser = gidUser, let profile = gidUser.profile {
                    let user = GoogleUser(
                        id: gidUser.userID ?? "",
                        displayName: profile.name,
                        email: profile.email,
                        photoURL: profile.imageURL(withDimension: 200)
                    )
                    
                    self?.currentUser = user
                    let accessToken = gidUser.accessToken.tokenString
                    let expiresIn = gidUser.accessToken.expirationDate?.timeIntervalSinceNow ?? 3600
                    
                    self?.storeSession(user: user, token: accessToken, expiresIn: expiresIn)
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}
