//
//  TestUtils.swift
//  noteappUITests
//
//  Created by Ibrahim Berat Kaya on 9.05.2021.
//

import XCTest

/// Sign in to the app.
func signIn(app: XCUIApplication) {
    let loginButton = app.buttons["loginButton"]
    XCTAssert(loginButton.exists)

    loginButton.tap()

    let emailTextField = app.textFields["emailTextField"]
    let passwordTextField = app.secureTextFields["passwordTextField"]
    let submitButton = app.buttons["submitButton"]

    XCTAssert(submitButton.exists)

    tapAndWrite(field: emailTextField, text: "beratkaya1998@gmail.com")

    tapAndWrite(field: passwordTextField, text: "berat12345")

    submitButton.tap()
}

/// Write to a XCUIElement (generally a TextField).
func tapAndWrite(field: XCUIElement, text: String) {
    XCTAssertTrue(field.exists, "\(field.label) XCUIElement doesn't exist")
    field.tap()
    field.typeText(text)
}

/// Dismiss the keyboard.
func dismissKeyboard(app: XCUIApplication) {
    app.toolbars.buttons["Done"].tap()
}
