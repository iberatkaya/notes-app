//
//  AuthUITests.swift
//  noteappUITests
//
//  Created by Ibrahim Berat Kaya on 9.05.2021.
//

import XCTest

class AuthUITests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// Test a successful login.
    func testLogin() throws {
        let app = XCUIApplication()
        
        // Delete the user from local storage.
        app.launchArguments += ["-reset-user"]
        
        // Launch the app.
        app.launch()
        
        signIn(app: app)
        
        // Expect the Home Page to appear.
        let homePage = app.otherElements["homePage"]
        
        let homePageExists = homePage.waitForExistence(timeout: TimeInterval(8))
        
        XCTAssert(homePageExists)
    }
    
    /// Test a successful login.
    func testUnsuccessfulLogin() throws {
        let app = XCUIApplication()
        
        // Delete the user from local storage.
        app.launchArguments += ["-reset-user"]
        
        // Launch the app.
        app.launch()
        
        let loginButton = app.buttons["loginButton"]
        XCTAssert(loginButton.exists)
        
        loginButton.tap()
        
        let submitButton = app.buttons["submitButton"]
        
        XCTAssert(submitButton.exists)
        
        submitButton.tap()
        
        // Expect the Home Page to not appear.
        let homePage = app.otherElements["homePage"]
        
        let homePageExists = homePage.waitForExistence(timeout: TimeInterval(8))
        
        XCTAssert(!homePageExists && submitButton.exists)
    }
}
