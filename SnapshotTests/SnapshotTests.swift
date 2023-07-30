//
//  SnapshotTests.swift
//  ALogUITests
//
//  Created by Xin Du on 2023/07/23.
//

import XCTest

final class SnapshotTests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        setupSnapshot(app)
        app.launch()
    }
    
    func testRecording() throws {
        let app = XCUIApplication()
        // 启动
        snapshot("01 - LaunchScreen")
        app.windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
        
        // 开始录音
        app.buttons["microphone"].tap()
        snapshot("02 - Recording")
        
        app.terminate()
    }
    
    func testSettings() throws {
        // 设置
        app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["nav_settings"].tap()
        snapshot("03 - Settings")
    }
    
}
