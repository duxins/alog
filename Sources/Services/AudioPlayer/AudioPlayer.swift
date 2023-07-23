//
//  AudioPlayer.swift
//  ALog
//
//  Created by Xin Du on 2023/07/16.
//

import AVFoundation

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    static let shared = AudioPlayer()
    
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var currentFile: String?
    
    convenience init(_ url: URL){
        self.init()
        load(url: url)
    }

    func load(url: URL) {
        audioPlayer?.stop()
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error loading audio player: \(error)")
        }
    }
    
    func play(file: String) {
        currentFile = file
        let url = FileHelper.fullAudioURL(for: file)
        load(url: url)
        play()
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
