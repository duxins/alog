//
//  SnapshotTests.swift
//  ALogUITests
//
//  Created by Xin Du on 2023/07/23.
//

import XCTest

final class SnapshotTests: XCTestCase {
    override class func setUp() {
        let app = XCUIApplication()
        app.launchArguments.append("--SnapshotTesting")
        setupSnapshot(app)
        app.launch()
    }
    
    func testRecording() throws {
        let app = XCUIApplication()
        snapshot("01 - LaunchScreen")
        app.windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
        app.buttons["Microphone"].tap()
        snapshot("02 - Recording")
        
        app.buttons["Stop"].tap()
        app.buttons["Trash"].tap()
        app.alerts["Are you sure?"].scrollViews.otherElements.buttons["Delete"].tap()
                
        XCUIApplication().navigationBars["_TtGC7SwiftUI32NavigationStackHosting"]/*@START_MENU_TOKEN@*/.buttons["nav_settings"]/*[[".otherElements[\"nav_settings\"].buttons[\"nav_settings\"]",".buttons[\"nav_settings\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        snapshot("03 - Settings")
    }
    
}
