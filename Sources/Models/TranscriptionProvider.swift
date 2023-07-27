//
//  TranscriptionProvider.swift
//  ALog
//
//  Created by Xin Du on 2023/07/14.
//

import Foundation

enum TranscriptionProvider: String, CaseIterable {
    case apple
    case openai
    
    var displayName: String {
        switch self {
        case .apple: return L(.trans_provider_apple)
        case .openai: return L(.trans_provider_openai)
        }
    }
    
    static var allowedCases: [TranscriptionProvider] {
        return [.apple]
    }
}
