//
//  Config.swift
//  ALog
//
//  Created by Xin Du on 2023/07/10.
//

import Foundation
import KeychainAccess
import SwiftUI
import Combine

class Config: ObservableObject {
    @AppStorage("day_start_time") var dayStartTime = 2
    @AppStorage("dark_mode") var darkMode = DarkMode.dark
    
    @AppStorage("trans_enabled") var transEnabled = false
    @AppStorage("trans_provider") var transProvider = TranscriptionProvider.apple
    @AppStorage("trans_lang") var transLang = TranscriptionLang.en
    
    @AppStorage("sum_enabled") var sumEnabled = false
    @AppStorage("sum_provider") var sumProvider = SummarizationProvider.openai
    
    @AppStorage("openai_model") var aiModel = OpenAIChatModel.gpt_3_5
    
    @Published var colorScheme = ColorScheme.light
    
    static let shared = Config()
    
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    private let KEY_NAME = "openai_key"
    
    private init() {
        if let key = keychain[string: KEY_NAME] {
            apiKey = key
        }
        
        $apiKey.map {
            !$0.isEmpty
        }.assign(to: &$isApiKeySet)
    }
    
    @Published var apiKey: String = "" {
        didSet {
            if apiKey.isEmpty {
                keychain[KEY_NAME] = nil
            } else {
                keychain[string: KEY_NAME] = apiKey
            }
        }
    }
    @Published var isApiKeySet: Bool = false
}
