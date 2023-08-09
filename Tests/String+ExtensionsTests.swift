//
//  String+FormattedHostNameTests.swift
//  ALogTests
//
//  Created by Xin Du on 2023/08/09.
//

import XCTest

@testable import ALog

final class String_ExtensionsTests: XCTestCase {
    
    func testFormattedHostName_WhenContainsSpaces_RemovesSpaces() {
        let input = " https: / /openai .com/  "
        XCTAssertEqual(input.formattedHostName(), "https://openai.com/")
    }

    func testFormattedHostName_WhenNoProtocol_AddsHTTPSPrefix() {
        let input = "openai.com"
        XCTAssertEqual(input.formattedHostName(), "https://openai.com/")
    }
    
    func testFormattedHostName_WhenNoTrailingSlash_AddsTrailingSlash() {
        let input = "https://openai.com"
        XCTAssertEqual(input.formattedHostName(), "https://openai.com/")
    }
    
    func testFormattedHostName_WhenTrailingSlashExists_RemainsUnchanged() {
        let input = "https://openai.com/"
        XCTAssertEqual(input.formattedHostName(), input)
    }

}
