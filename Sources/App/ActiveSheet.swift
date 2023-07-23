//
//  ActiveSheet.swift
//  ALog
//
//  Created by Xin Du on 2023/07/22.
//

import Foundation

enum ActiveSheet: Identifiable {
    case settings
    /// Generate summary
    case summarize(SummaryItem)
    
    var id: String {
        switch self {
        case .settings: return "settings"
        case .summarize(let item): return item.id
        }
    }
}
