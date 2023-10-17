//
//  DateHelperTests.swift
//  ALogTests
//
//  Created by Xin Du on 2023/10/18.
//

import XCTest
@testable import ALog

final class DateHelperTests: XCTestCase {
    func testIdentifier() {
        let date1 = createDate(year: 2023, month: 10, day: 1)
        XCTAssertEqual(DateHelper.identifier(from: date1), 20231001)
        
        let date2 = createDate(year: 2023, month: 1, day: 1)
        XCTAssertEqual(DateHelper.identifier(from: date2), 20230101)
        
        let date3 = createDate(year: 2023, month: 12, day: 31, hour: 23)
        XCTAssertEqual(DateHelper.identifier(from: date3), 20231231)
    }
    
    func testRealDate_WhenTimeIsBeforeStartOfDay_ReturnsPreviousDay() {
        Config.shared.dayStartTime = 1
        // 2023/10/1 00:01 -> 2023/09/30
        let date1 = createDate(year: 2023, month: 10, day:  1, hour: 0, minute: 1)
        let prev1 = createDate(year: 2023, month: 9,  day: 30)
        XCTAssertEqual(date1.realDate, prev1)
        // 2023/01/01 00:59 -> 2022/12/31
        let date2 = createDate(year: 2023, month:  1, day: 1, hour: 0, minute: 59)
        let prev2 = createDate(year: 2022, month: 12, day: 31)
        XCTAssertEqual(date2.realDate, prev2)
        
        Config.shared.dayStartTime = 2
        // 2023/01/01 01:30 -> 2022/12/31
        let date3 = createDate(year: 2023, month:  1, day:  1, hour: 1, minute: 30)
        let prev3 = createDate(year: 2022, month: 12, day: 31)
        XCTAssertEqual(date3.realDate, prev3)
    }
    
    func testRealDate_WhenTimeIsEqualToOrAfterStartOfDay_ReturnsSameDay() {
        Config.shared.dayStartTime = 1
        // 2023/11/10 01:00
        let date1 = createDate(year: 2023, month:  11, day: 10, hour: 1)
        XCTAssertEqual(date1.realDate, Calendar.current.startOfDay(for: date1))
        
        // 2023/10/01 01:01
        let date2 = createDate(year: 2023, month: 10, day: 1, hour: 1, minute: 1)
        XCTAssertEqual(date2.realDate, Calendar.current.startOfDay(for: date2))
    }
    
    // MARK: - Helper Methods
    private func createDate(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        let calendar = Calendar.current
        return calendar.date(from: dateComponents)!
    }
}
