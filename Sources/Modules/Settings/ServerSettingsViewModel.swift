//
//  ServerSettingsViewModel.swift
//  ALog
//
//  Created by Xin Du on 2023/07/14.
//

import Foundation
import SwiftUI
import Combine
import XLog

enum ServerVerificationItem: CaseIterable {
    case chat
    case whisper
    
    var displayName: String {
        switch self {
        case .chat: return L(.settings_server_verify_item_chat)
        case .whisper: return L(.settings_server_verify_item_whisper)
        }
    }
}

enum ServerVerificationStatus: Equatable {
    case pending
    case inProgress
    case success
    case failure(String)
}

class ServerSettingsViewModel: ObservableObject {
    @Published var isVerifying = false {
        didSet {
            if isVerifying {
                for k in verificationItems.keys {
                    verificationItems[k] = .pending
                }
            }
        }
    }
    @Published var lastErrorMessage = "" {
        didSet {
            showError = true
        }
    }
    @Published var showError = false
    @Published var isVerified = false
    
    @Published var host = Constants.OpenAI.api_host
    @Published var requiresKey = false
    @Published var key = ""
    
    @Published var verificationItems: [ServerVerificationItem: ServerVerificationStatus] = [ .chat: .pending, .whisper: .pending ]
    
    @Published var isServerValid = false
    
    private let config = Config.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Publishers.CombineLatest3($host, $requiresKey, $key)
            .sink { [unowned self] combine in
                if combine.1 {
                    isServerValid = !combine.0.isEmpty && !combine.2.isEmpty
                } else {
                    isServerValid = !combine.0.isEmpty
                }
                isVerified = false
            }
            .store(in: &cancellables)
        
        $requiresKey.sink { [unowned self] v in
            if v == false {
                key = ""
            }
        }.store(in: &cancellables)
    }
    
    deinit{
        #if DEBUG
        XLog.debug("✖︎ ServerSettingsViewModel", source: "Server")
        #endif
    }
    
    func verify() {
        guard isVerifying == false else { return }
        
        host = host.formattedHostName()
        
        isVerifying = true
        
        Task { @MainActor in
            let keyToUse = requiresKey ? key : nil
            
            // 测试 chat
            verificationItems[.chat] = .inProgress
            do {
                try await OpenAIClient.shared.verify(host, key: keyToUse)
                verificationItems[.chat] = .success
            } catch {
                verificationItems[.chat] = .failure(ErrorHelper.desc(error))
            }
            
            // 测试 Whisper
            verificationItems[.whisper] = .inProgress
            do {
                try await OpenAIClient.shared.verifyWhisper(host, key: keyToUse)
                verificationItems[.whisper] = .success
            } catch {
                verificationItems[.whisper] = .failure(ErrorHelper.desc(error))
            }
            
            // 只要有一项验证通过即可
            isVerified = verificationItems.filter { $0.value == .success }.count > 0
            isVerifying = false
        }
        
    }
    
    func save() {
        config.serverHost = host
        config.serverAPIKey = requiresKey ? key : ""
    }
    
    func load() {
        host = config.serverHost
        requiresKey = !config.serverAPIKey.isEmpty
        key = config.serverAPIKey
    }
}
