//
//  MapProjectUITests.swift
//  MapProjectUITests
//
//  Created by Xcode User on 2020-11-05.

//  Copyright © 2020 Xcode User. All rights reserved.
//

import XCTest
import MapKit
import UIKit

class MapProjectUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.buttons["Lets Begin"].tap()
        
        let letsGoButton = app.navigationBars["My Map"].buttons["Lets GO!"]

        XCTAssertNotNil(letsGoButton)
        

        app.textFields["Waypoint#1"].tap()
        app.textFields["Waypoint#1"].typeText("Toronto")

        app.textFields["Waypoint#2"].tap()
        app.textFields["Waypoint#2"].typeText("Brampton")

        app.textFields["Destination"].tap()
        app.textFields["Destination"].typeText("Montreal")

        app.navigationBars["My Map"].buttons["Lets GO!"].tap()
        
        
        
        
        
        
        
        
        
    }

}
