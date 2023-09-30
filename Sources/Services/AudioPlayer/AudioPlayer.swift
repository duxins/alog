//
//  AudioPlayer.swift
//  ALog
//
//  Created by Xin Du on 2023/07/16.
//

import AVFoundation
import XLog

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    static let shared = AudioPlayer()
    
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var currentFile: String?
    
    convenience init(_ url: URL){
        self.init()
        try? load(url: url)
    }

    func load(url: URL) throws {
        audioPlayer?.stop()
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.delegate = self
        audioPlayer?.prepareToPlay()
    }
    
    func play(file: String) {
        currentFile = file
        let url = FileHelper.fullAudioURL(for: file)
        do {
            try load(url: url)
            play()
        } catch {
            XLog.error(error, source: "Player")
        }
    }
    
    func play() {
        audioPlayer?.play()
        isPlaying = true
    }
    
    func stop() {
        guard isPlaying else { return }
        currentFile = nil
        audioPlayer?.stop()
        isPlaying = false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            player.currentTime = 0
        }
        isPlaying = false
    }
}
