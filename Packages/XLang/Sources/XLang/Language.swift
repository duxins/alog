//
//  Language.swift
//  
//  Created by Xin Du on 2023/05/05.
//

import Foundation

public enum Language: String, CaseIterable {
    /// 英文
    case en = "en"
    /// 简体中文
    case zh_hans = "zh-Hans"
    
    public var displayName: String {
        switch self {
        case .en: return "English"
        case .zh_hans: return "简体中文"
        }
    }
    
    public func toLocale() -> Locale {
        return Locale(identifier: self.rawValue)
    }
    
    public init?(_ locale: Locale) {
        if let value = Language(rawValue: locale.identifier) {
            self = value
        } else {
            return nil
        }
    }
}
