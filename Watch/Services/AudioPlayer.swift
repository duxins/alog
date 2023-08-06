//
//  AudioPlayer.swift
//  ALogWatch
//
//  Created by Xin Du on 2023/08/06.
//

import AVFoundation
import XLog

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    static let shared = AudioPlayer()
    
    private var audioPlayer: AVAudioPlayer?
    
    @Published var isPlaying = false
    @Published var timeElapsed: Double = 0
    @Published var duration: Double = 0
    @Published var volume: Double = 0
    
    var timer: Timer?
    private var volumeObserver: Any?
    
    convenience init(_ url: URL){
        self.init()
        load(url: url)
        
        volumeObserver = AVAudioSession.sharedInstance().observe(\.outputVolume) { [weak self] session, _ in
            print("Output volume: \(session.outputVolume)")
            self?.volume = Double(session.outputVolume)
        }
    }
    
    deinit {
        #if DEBUG
        XLog.debug("✖︎ AudioPlayer", source: "Player")
        #endif
    }

    func load(url: URL) {
        audioPlayer?.stop()
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
        } catch {
            XLog.error(error, source: "Player")
        }
    }
    
    func play() {
        audioPlayer?.play()
        isPlaying = true
        startTimer()
        duration = audioPlayer?.duration ?? 0
    }
    
    func stop() {
        timer?.invalidate()
        guard isPlaying else { return }
        audioPlayer?.stop()
        isPlaying = false
        resetPlayer()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.timeElapsed = Double(self.audioPlayer?.currentTime ?? 0)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        XLog.info("audio player did finish playing with flag \(flag)", source: "Player")
        isPlaying = false
        resetPlayer()
    }
    
    private func resetPlayer() {
        timeElapsed = 0
        audioPlayer?.currentTime = 0
    }
}
