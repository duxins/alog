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

class AppState: ObservableObject {
    static let shared = AppState()
    private init() {}
    
    private let l10n = XLang.shared
    
    @Published var language: Language = XLang.shared.currentLang {
        didSet {
            l10n.setLang(language)
        }
    }
    
    @Published var micPermission: AVAudioSession.RecordPermission = .undetermined
    
    @Published var activeSheet: ActiveSheet?
    @Published var activeTab: Int = 0
    
    func checkMicPermission() {
        let audioSession = AVAudioSession.sharedInstance()
        micPermission = audioSession.recordPermission
    }
}
