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
    @Published var showRecording = false
    
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
    
    func startRecording() {
        guard showRecording == false else { return }
        guard micPermission != .denied else {
            activeSheet = .micPermission
            return
        }
        activeSheet = nil
        activeTab = 0
        AudioPlayer.shared.stop()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.showRecording = true
        }
    }
    
    func startCreatingNote() {
        guard showRecording == false else { return }
        guard activeSheet != .quickMemo else { return }
        activeSheet = nil
        activeTab = 0
        AudioPlayer.shared.stop()
        self.activeSheet = .quickMemo
    }

    func startSummarizing() {
        guard Config.shared.sumEnabled else { return }
        guard showRecording == false else { return }
        if case .summarize = activeSheet { return }
        let today = DateHelper.identifier(from: Date().realDate)
        activeSheet = nil
        activeTab = 0
        activeSheet = .summarize(SummaryItem.day(today))
    }
    
    func openURL(_ url: URL) {
        guard let host = url.host() else { return }
        switch host {
        case "record":
            startRecording()
        case "note":
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let textItem = components.queryItems?.first(where: { $0.name == "text" }),
               let text = textItem.value, !text.isEmpty {
                saveQuickNote(text: text)
            } else {
                startCreatingNote()
            }
        case "summarize":
            startSummarizing()
        default: return
        }
    }
    
    private func saveQuickNote(text: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            let viewModel = QuickMemoViewModel()
            viewModel.content = text
            viewModel.save()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    func canStartRecording() -> Bool {
        guard showRecording == false else { return false }
        guard micPermission != .denied else {
            activeSheet = .micPermission
            return false
        }
        activeSheet = nil
        activeTab = 0
        AudioPlayer.shared.stop()
        return true
    }
    
}
