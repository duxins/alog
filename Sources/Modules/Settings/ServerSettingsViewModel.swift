//
//  ServerSettingsViewModel.swift
//  ALog
//
//  Created by Xin Du on 2023/07/14.
//

import Foundation
import SwiftUI
import Combine

class ServerSettingsViewModel: ObservableObject {
    @Published var isVerifying = false
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
    
    func verify() {
        guard isVerifying == false else { return }
        
        host = host.replacingOccurrences(of: " ", with: "")
        
        if !host.isEmpty && host.suffix(1) != "/" {
            host = host + "/"
        }
        
        isVerifying = true
        
        Task { @MainActor in
            do {
                let _ = try await OpenAIClient.shared.verify(host, key: requiresKey ? key : nil)
                isVerified = true
            } catch {
                lastErrorMessage = ErrorHelper.desc(error)
            }
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
