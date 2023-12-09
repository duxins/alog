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
    case zh_hant_hk
    case ja
    
    var displayName: String {
        switch self {
        case .auto: return L(.trans_lang_auto)
        case .en: return L(.trans_lang_en)
        case .ja: return L(.trans_lang_ja)
        case .zh_hans: return L(.trans_lang_zh_hans)
        case .zh_hant_hk: return L(.trans_lang_zh_hant_hk)
        }
    }
    
    var whisperLangCode: String {
        switch self {
        case .en: return "en"
        case .ja: return "ja"
        case .zh_hans: return "zh"
        case .zh_hant_hk: return "zh"
        default: return ""
        }
    }
    
    var localeIdentifier: String? {
        switch self {
        case .auto: return nil
        case .en: return "en-US"
        case .ja: return "ja-JP"
        case .zh_hans: return "zh-Hans"
        case .zh_hant_hk: return "zh-Hant_HK"
        }
    }
    
    var whisperPrompt: String? {
        switch self {
        case .zh_hans: return "以下是普通话的句子。" + (customWhisperPrompt ?? "")
        case .zh_hant_hk: return "以下係粵語句子。" + (customWhisperPrompt ?? "")
        default: return customWhisperPrompt
        }
    }
    
    var customWhisperPrompt: String? {
        guard Config.shared.customWhisperPromptEnabled else { return nil }
        return Config.shared.customWhisperPrompt
    }
}

