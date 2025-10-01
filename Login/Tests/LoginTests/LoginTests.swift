import XCTest
@testable import Login

final class LoginTests: XCTestCase {
    
    func testLoginModuleInitialization() throws {
        // Test that the Login module can be initialized
        let login = Login()
        XCTAssertNotNil(login)
    }
    
    func testGoogleLoginButtonCreation() throws {
        // Test that we can create a Google login button
        let button = Login.googleLoginButton {
            // Test action
        }
        XCTAssertNotNil(button)
    }
    
    func testGoogleBrandLoginButtonCreation() throws {
        // Test that we can create a Google brand login button
        let button = Login.googleBrandLoginButton {
            // Test action
        }
        XCTAssertNotNil(button)
    }
}
