//
//  QuipoUITests.swift
//  QuipoUITests
//
//  Created by Mikhail Yakushin on 8/6/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
//

import XCTest

class QuipoUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {

      
      
      let app = XCUIApplication()
      app.scrollViews.otherElements.containingType(.StaticText, identifier:"Sign In    and start sharing your thoughts").childrenMatchingType(.Button).elementBoundByIndex(3).tap()
      app.textFields["Email or Phone"].tap()
      app.textFields["Email or Phone"].typeText("driver733@me.com")
      app.secureTextFields["Facebook Password"].tap()
      app.secureTextFields["Facebook Password"].typeText("18Sasobu\r")
      app.buttons["OK"].tap()
      app.tabBars.childrenMatchingType(.Button).matchingIdentifier("Item").elementBoundByIndex(0).tap()
      app.navigationBars["Quipo.ProfileVC"].buttons["Settings"].tap()
      
      let tablesQuery = app.tables
      tablesQuery.staticTexts["2 facebook friends"].tap()
      
      let backButton = app.navigationBars["Quipo.DetailedSettingsVC"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0)
      backButton.tap()
  //    app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Table).element.swipeUp()
      tablesQuery.staticTexts["Linked Accounts"].tap()
      backButton.tap()
      
      
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
