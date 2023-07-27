//
//  DateHelper.swift
//  ALog
//
//  Created by Xin Du on 2023/07/12.
//

import Foundation

class DateHelper {
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        return formatter
    }()
    
    static func components(from identifier: Int) -> DateComponents {
        let y = identifier / 10000, m = identifier / 100 % 100, d = identifier % 100
        var components = DateComponents()
        components.year = y
        components.month = m
        components.day = d
        return components
    }
    
    static func date(from identifier: Int) -> Date? {
        let components = components(from: identifier)
        return Calendar.current.date(from: components)
    }
    
    static func format(_ date: Date, dateFormat: String? = nil) -> String {
        if let dateFormat {
            formatter.dateFormat = dateFormat
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
        }
        return formatter.string(from: date)
    }
    
    static func formatIdentifier(_ identifier: Int, dateFormat: String? = nil) -> String {
        guard let date = Calendar.current.date(from: components(from: identifier)) else { return "" }
        return format(date, dateFormat: dateFormat)
    }
    
    static func identifier(from date: Date) -> Int {
        formatter.dateFormat = "yyyyMMdd"
        return Int(formatter.string(from: date))!
    }
    
    static func todayIdentifier() -> Int {
        var date = Date()
        let hour = Calendar.current.component(.hour, from: date)
        if hour < Config.shared.dayStartTime {
            date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
        }
        return identifier(from: date)
    }
    
    static func timeToDate(h: Int, m: Int, s: Int = 0) -> Date {
        var components = DateComponents()
        components.hour = h
        components.minute = m
        components.second = s
        return Calendar.current.date(from: components) ?? Date()
    }
}
