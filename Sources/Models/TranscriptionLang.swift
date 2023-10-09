//
//  TranscriptionLang.swift
//  ALog
//
//  Created by Xin Du on 2023/07/14.
//

import Foundation

enum TranscriptionLang: String, CaseIterable {
    case auto
    case en
    case zh_hans
    case ja
    
    var displayName: String {
        switch self {
        case .auto: return L(.trans_lang_auto)
        case .en: return L(.trans_lang_en)
        case .ja: return L(.trans_lang_ja)
        case .zh_hans: return L(.trans_lang_zh_hans)
        }
    }
    
    var whisperLangCode: String {
        switch self {
        case .en: return "en"
        case .ja: return "ja"
        case .zh_hans: return "zh"
        default: return ""
        }
    }
    
    var localeIdentifier: String? {
        switch self {
        case .auto: return nil
        case .en: return "en-US"
        case .ja: return "ja-JP"
        case .zh_hans: return "zh-Hans"
        }
    }
    
    var whisperPrompt: String? {
        switch self {
        case .zh_hans: return "以下是普通话的句子。" + (customWhisperPrompt ?? "")
        default: return customWhisperPrompt
        }
    }
    
    var customWhisperPrompt: String? {
        guard Config.shared.customWhisperPromptEnabled else { return nil }
        return Config.shared.customWhisperPrompt
    }
}

