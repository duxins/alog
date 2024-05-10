//
//  AudioRecorder.swift
//  ALog
//
//  Created by Xin Du on 2023/07/09.
//

import Foundation
import XLog
import AVFoundation

class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var isCompleted = false
    @Published var recordedTime: Int = 0
    @Published var voiceFile: URL?
    @Published var samples: [Float] = []
    
    var didFinishCallback: (() -> Void)?
    
    private var recorder: AVAudioRecorder!
    private var session: AVAudioSession!
    private var timer: Timer?
    
    private var isTerminating = false
    
    var formattedTime: String {
        String(format: "%02d:%02d", recordedTime / 60, recordedTime % 60)
    }
    
    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
        
        #if DEBUG
            XLog.debug("✖︎ Audio Recorder", source: "Audio")
        #endif
    }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc private func handleInterruption(notification: Notification) {
        if let info = notification.userInfo,
            let typeInt = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeInt) {
            if type == .began && isRecording {
                stopRecording()
            }
        }
    }
    
    func startRecording() {
        guard isRecording == false else {
            return
        }
        self.isTerminating = false
        requestPermissionAndStartRecording()
    }
    
    func stopRecording() {
        XLog.debug("stop recording", source: "Audio")
        
        guard recorder != nil, isRecording else {
            return
        }
        
        recorder.stop()
        
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setMode(.default)
    }
    
    func terminate() {
        XLog.debug("terminating recording", source: "Audio")
        guard isRecording else { return }
        self.isTerminating = true
        stopRecording()
        recorder.deleteRecording()
    }
    
    static func requestPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission() { allowed in
            DispatchQueue.main.async {
                #if os(iOS)
                AppState.shared.micPermission = AVAudioSession.sharedInstance().recordPermission
                #else
                WatchAppState.shared.micPermission = AVAudioSession.sharedInstance().recordPermission
                #endif
            }
        }
    }
    
    private func requestPermissionAndStartRecording() {
        do {
            session = AVAudioSession.sharedInstance()
            try session.setAllowHapticsAndSystemSoundsDuringRecording(true)
            #if os(iOS)
            try session.setCategory(.playAndRecord, mode: .voiceChat, options: [.duckOthers, .allowBluetooth])
            #else
            try session.setCategory(.playAndRecord, mode: .default, options: .duckOthers)
            #endif
            try session.setActive(true)
            session.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    #if os(iOS)
                    AppState.shared.micPermission = AVAudioSession.sharedInstance().recordPermission
                    #else
                    WatchAppState.shared.micPermission = AVAudioSession.sharedInstance().recordPermission
                    #endif
                    if allowed {
                        self.record()
                    }
                }
            }
        } catch {
            XLog.error(error)
        }
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { timer in
            self.recordedTime = Int(self.recorder.currentTime)
            
            #if os(iOS)
            self.recorder.updateMeters()
            let linear = 1 - pow(10, self.recorder.averagePower(forChannel: 0) / 20)
            self.samples += [linear, linear]
            #endif
        })
    }
    
    private func stopMonitoring() {
        timer?.invalidate()
    }
    
    private func record() {
        let url = tmpFileURL()
        XLog.debug("Save audio file to \(url.absoluteString)", source: "Audio")
        
        let settings = [
           AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
           AVSampleRateKey: 24000,
           AVNumberOfChannelsKey: 1,
           AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]
        
        do {
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord()
            recorder.record()
            isRecording = true
            startMonitoring()
        } catch {
            XLog.error("Failed to start audio engine: \(error.localizedDescription)")
        }
    }
    
    private func tmpFileURL(_ name: String? = nil) -> URL {
        let fileName = name ?? UUID().uuidString.lowercased() + ".m4a"
        let tmpDirURL = URL(filePath: NSTemporaryDirectory())
        return tmpDirURL.appendingPathComponent(fileName)
    }
    
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        XLog.info("audio recorder did finish recording with flag \(flag)", source: "Audio")
        
        if flag && !isTerminating {
            voiceFile = recorder.url
            isCompleted = true
        }
        
        didFinishCallback?()
        stopMonitoring()
        isRecording = false
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error {
            voiceFile = nil
            XLog.error("audio recorder encode error: \(error.localizedDescription)", source: "Audio")
        }
        stopMonitoring()
        isRecording = false
    }
}

