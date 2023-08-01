//
//  AppState.swift
//  ALog
//
//  Created by Xin Du on 2023/07/09.
//

import Foundation
import AVFoundation

import XLog
import XLang
import SwiftUI
import KeychainAccess

class AppState: ObservableObject {
    static let shared = AppState()
    
    private init() {
        if UserDefaults.standard.bool(forKey: PREMIUM_KEY) {
            isPremium = true
            UserDefaults.standard.removeObject(forKey: PREMIUM_KEY)
        } else {
            isPremium = keychain[string: PREMIUM_KEY] != nil
        }
    }
    
    private let l10n = XLang.shared
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    
    @Published var language: Language = XLang.shared.currentLang {
        didSet {
            l10n.setLang(language)
        }
    }
    
    @Published var micPermission: AVAudioSession.RecordPermission = .undetermined
    
    @Published var activeSheet: ActiveSheet?
    @Published var activeTab: Int = 0
    
    private let PREMIUM_KEY = "is_premium"
    @Published var isPremium: Bool = false {
        didSet {
            if isPremium == false {
                keychain[PREMIUM_KEY] = nil
            } else {
                keychain[string: PREMIUM_KEY] = "1"
            }
        }
    }
    
    func checkMicPermission() {
        let audioSession = AVAudioSession.sharedInstance()
        micPermission = audioSession.recordPermission
    }
}
