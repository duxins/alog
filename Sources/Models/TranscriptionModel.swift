//
//  TranscriptionModel.swift
//  ALog
//
//  Created by Xin Du on 2025/03/22.
//

import Foundation

enum TranscriptionModel: String, CaseIterable {
    case whisper_1
    case gpt_4o_mini_transcribe
    case gpt_4o_transcribe
    
    var displayName: String {
        switch self {
        case .whisper_1: return "Whisper-1"
        case .gpt_4o_mini_transcribe: return "GPT-4o mini"
        case .gpt_4o_transcribe: return "GPT-4o"
        }
    }
    
    var name: String {
        switch self {
        case .whisper_1: return "whisper-1"
        case .gpt_4o_mini_transcribe: return "gpt-4o-mini-transcribe"
        case .gpt_4o_transcribe: return "gpt-4o-transcribe"
        }
    }
    
    static var defaultServerModels: [TranscriptionModel] {
        return [.whisper_1, .gpt_4o_mini_transcribe]
    }
    
    static var customServerModels: [TranscriptionModel] {
        return [.whisper_1, .gpt_4o_mini_transcribe, .gpt_4o_transcribe]
    }
    
    static func isModelAvailable(_ model: TranscriptionModel, for serverType: ServerType) -> Bool {
        switch serverType {
        case .app:
            return defaultServerModels.contains(model)
        case .custom:
            return customServerModels.contains(model)
        }
    }
} 
