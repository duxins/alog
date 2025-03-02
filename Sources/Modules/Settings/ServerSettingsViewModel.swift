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
    case gpt_4o
    case whisper
    
    var displayName: String {
        switch self {
        case .gpt_4o: return "GPT-4o"
        case .whisper: return "Whisper"
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
    
    @Published var verificationItems: [ServerVerificationItem: ServerVerificationStatus] = [ .gpt_4o: .pending, .whisper: .pending ]
    
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
            
            // 测试 gpt_4
            verificationItems[.gpt_4o] = .inProgress
            do {
                try await OpenAIClient.shared.verify(host, key: keyToUse, model: .gpt_4o)
                verificationItems[.gpt_4o] = .success
            } catch {
                verificationItems[.gpt_4o] = .failure(ErrorHelper.desc(error))
            }
            
            // 测试 Whisper
            verificationItems[.whisper] = .inProgress
            do {
                try await OpenAIClient.shared.verifyWhisper(host, key: keyToUse)
                verificationItems[.whisper] = .success
            } catch {
                verificationItems[.whisper] = .failure(ErrorHelper.desc(error))
            }
            
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
