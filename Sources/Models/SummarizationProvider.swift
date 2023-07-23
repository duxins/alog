//
//  SumService.swift
//  ALog
//
//  Created by Xin Du on 2023/07/14.
//

import Foundation

enum SummarizationProvider: String, CaseIterable {
    case openai
    
    var displayName: String {
        switch self {
        case .openai: return L(.sum_service_openai)
        }
    }
}
