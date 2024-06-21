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

struct StartupOption {
    static let record = "record"
    static let createNote = "create_note"
}

class Config: ObservableObject {
    @AppStorage("day_start_time") var dayStartTime = 2
    @AppStorage("dark_mode") var darkMode = DarkMode.dark
    @AppStorage("server_type") var serverType = ServerType.app
    
    @AppStorage("trans_enabled") var transEnabled = false
    @AppStorage("trans_provider") var transProvider = TranscriptionProvider.apple
    @AppStorage("trans_lang") var transLang = TranscriptionLang.auto
    
    @AppStorage("sum_enabled") var sumEnabled = false
    
    @AppStorage("openai_model") var aiModel = OpenAIChatModel.gpt_3_5
    
    @AppStorage("auto_save") var autoSave = true
    
    @AppStorage("server_host") var serverHost = "" {
        didSet {
            validateHost()
        }
    }
    
    // MARK: - Experimental Features
    
    /// 自定义 whisper 提示词
    @AppStorage("custom_whisper_prompt_enabled") var customWhisperPromptEnabled = false
    @AppStorage("custom_whisper_prompt") var customWhisperPrompt = ""
    
    /// Hold to Record
    @AppStorage("hold_to_record_enabled") var holdToRecordEnabled = false
    
    /// Auto Record / Create Note On Startup
    @AppStorage("auto_start_on_startup") var autoStartOnStartup = ""
    
    @Published var colorScheme = ColorScheme.light
    
    static let shared = Config()
    
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    
    private let KEY_NAME = "openai_api_key"
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        serverAPIKey = keychain[string: KEY_NAME] ?? ""
        validateHost()
    }
    
    private func validateHost() {
        isServerSet = !serverHost.isEmpty
    }
    
    @Published var serverAPIKey: String = "" {
        didSet {
            if serverAPIKey.isEmpty {
                keychain[KEY_NAME] = nil
            } else {
                keychain[string: KEY_NAME] = serverAPIKey
            }
        }
    }
    
    @Published var isServerSet: Bool = false
    
    var isServerValid: Bool {
        guard serverType == .custom else { return true }
        if let _ = URL(string: serverHost) {
            return true
        }
        return false
    }
}
