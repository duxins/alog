//
//  SummaryItem.swift
//  ALog
//
//  Created by Xin Du on 2023/07/20.
//

import Foundation

enum SummaryItem: Identifiable {
    case day(Int)
    
    var id: String {
        switch self {
        case .day(let n):
            return String(n)
        }
    }
}
