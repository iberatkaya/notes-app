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
        app.launchArguments += ["-reset-user"]
        app.launch()
        
        let loginButton = app.buttons["loginButton"]
        XCTAssert(loginButton.exists)
        
        loginButton.tap()
        
        let emailTextField = app.textFields["emailTextField"]
        let passwordTextField = app.secureTextFields["passwordTextField"]
        let submitButton = app.buttons["submitButton"]
        
        XCTAssert(submitButton.exists)
        
        _tapAndWrite(field: emailTextField, text: "beratkaya1998@gmail.com")
        
        _tapAndWrite(field: passwordTextField, text: "berat12345")
        
        submitButton.tap()
        
        let homePage = app.otherElements["homePage"]
        
        let homePageExists = homePage.waitForExistence(timeout: TimeInterval(10))
        
        XCTAssert(homePageExists)
    }
    
    /// Test a successful login.
    func testUnsuccessfulLogin() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-reset-user"]
        app.launch()
        
        let loginButton = app.buttons["loginButton"]
        XCTAssert(loginButton.exists)
        
        loginButton.tap()
        
        let submitButton = app.buttons["submitButton"]
        
        XCTAssert(submitButton.exists)
        
        submitButton.tap()
        
        let homePage = app.otherElements["homePage"]
        
        let homePageExists = homePage.waitForExistence(timeout: TimeInterval(10))
        
        XCTAssert(!homePageExists && submitButton.exists)
    }
    
    /// Write to a XCUIElement (generally a TextField).
    func _tapAndWrite(field: XCUIElement, text: String) {
        XCTAssertTrue(field.exists, "\(field.label) XCUIElement doesn't exist")
        field.tap()
        field.typeText(text)
    }
}
