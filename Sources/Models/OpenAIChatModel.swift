//
//  OpenAIChatModel.swift
//  ALog
//
//  Created by Xin Du on 2023/07/10.
//

import Foundation

enum OpenAIChatModel: String, CaseIterable {
    case gpt_3_5
    case gpt_3_5_16k
    case gpt_4
    
    var displayName: String {
        switch self {
        case .gpt_3_5: return "GPT-3.5-turbo"
        case .gpt_3_5_16k: return "GPT-3.5-turbo-16k"
        case .gpt_4: return "GPT-4"
        }
    }
    
    var name: String {
        switch self {
        case .gpt_3_5: return "gpt-3.5-turbo"
        case .gpt_3_5_16k: return "gpt-3.5-turbo-16k"
        case .gpt_4: return "gpt-4"
        }
    }
}
