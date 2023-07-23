//
//  OpenAISettingsViewModel.swift
//  ALog
//
//  Created by Xin Du on 2023/07/14.
//

import Foundation
import SwiftUI

class OpenAISettingsViewModel: ObservableObject {
    @Published var isVerifying = false
    @Published var lastErrorMessage = "" {
        didSet {
            showError = true
        }
    }
    @Published var showError = false
    @Published var isKeyVerified = false
    
    init() {
        
    }
    
    func verify(_ key: String) {
        guard isVerifying == false else { return }
        isVerifying = true
        
        Task { @MainActor in
            do {
                let _ = try await OpenAIClient.shared.verify(key)
                isKeyVerified = true
            } catch {
                lastErrorMessage = ErrorHelper.desc(error)
            }
            isVerifying = false
        }
    }
}
