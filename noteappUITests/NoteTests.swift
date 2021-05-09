//
//  NoteTest.swift
//  noteappUITests
//
//  Created by Ibrahim Berat Kaya on 9.05.2021.
//

import XCTest

class NoteTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddNote() throws {
        let app = XCUIApplication()
        
        // Delete the user from local storage.
        app.launchArguments += ["-reset-user"]
        
        // Launch the app.
        app.launch()
        
        signIn(app: app)
        
        // Expect the Home Page to appear.
        let appLabel = app.staticTexts["appLabel"]
        
        
        let appLabelExists = appLabel.waitForExistence(timeout: TimeInterval(12))
        
        
        XCTAssert(appLabelExists)
        
        // Tap the Add Note button.
        let addNoteButton = app.buttons["addNoteButton"]
        
        let addNoteButtonExists = addNoteButton.waitForExistence(timeout: TimeInterval(4))
        
        
        XCTAssert(addNoteButtonExists)
        addNoteButton.tap()
        
        // Expect the Add Note Page TextFields to appear.
        let titleTextField = app.textFields["titleTextField"]
        let bodyTextField = app.textViews["bodyTextField"]
        
        XCTAssert(titleTextField.exists && bodyTextField.exists)
        
        // Write to the text fields.
        let uuid = UUID().uuidString
        let testNoteTitle = "Test Title \(uuid)"
        
        tapAndWrite(field: titleTextField, text: testNoteTitle)
        tapAndWrite(field: bodyTextField, text: "Test body.")
        
        // Submit the note.
        let addNoteSubmitButton = app.buttons["addNoteSubmitButton"]
        
        XCTAssert(addNoteSubmitButton.exists)
        
        dismissKeyboard(app: app)
        
        addNoteSubmitButton.tap()
        
        // Expect the note to appear again.
        let appLabelExistsAgain = appLabel.waitForExistence(timeout: TimeInterval(8))
        
        XCTAssert(appLabelExistsAgain)
        
        // Expect the new note to appear.
        let newNote = app.staticTexts[testNoteTitle]
        
        XCTAssert(newNote.exists)
    }
}
