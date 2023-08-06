//
//  WatchAppState.swift
//  ALogWatch
//
//  Created by Xin Du on 2023/08/05.
//

import Foundation
import AVFoundation

class WatchAppState: ObservableObject {
    static let shared = WatchAppState()
    private init() {}
    
    @Published var micPermission: AVAudioSession.RecordPermission = .undetermined
    
    func checkMicPermission() {
        micPermission = AVAudioSession.sharedInstance().recordPermission
    }
    
}
