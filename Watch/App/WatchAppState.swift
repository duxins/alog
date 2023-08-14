//
//  WatchAppState.swift
//  ALogWatch
//
//  Created by Xin Du on 2023/08/05.
//

import Foundation
import AVFoundation
import WatchKit

class WatchAppState: ObservableObject {
    static let shared = WatchAppState()
    private init() {}
    
    @Published var micPermission: AVAudioSession.RecordPermission = .undetermined
    @Published var showRecording = false
    @Published var showPermissionAlert = false
    
    func checkMicPermission() {
        micPermission = AVAudioSession.sharedInstance().recordPermission
    }
    
    func startRecording() {
        guard showRecording == false else { return }
        WKInterfaceDevice.current().play(.start)
        guard micPermission != .denied else {
            showPermissionAlert = true
            return
        }
        AudioPlayer.shared.stop()
        showRecording = true
    }
    
    func openURL(_ url: URL) {
        guard let host = url.host() else { return }
        switch host {
        case "record":
            startRecording()
        default: return
        }
    }
}
