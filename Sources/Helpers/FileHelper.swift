//
//  FileHelper.swift
//  ALog
//
//  Created by Xin Du on 2023/07/15.
//

import Foundation
import AVFoundation
import XLog

class FileHelper {
    static let AUDIO_FOLDER = "audio"
    
    static func moveAudioFile(_ srcURL: URL) throws -> URL {
        let fs = FileManager.default
        let audioDirURL = URL.documentsDirectory.appendingPathComponent(AUDIO_FOLDER)
        
        if !fs.fileExists(atPath: audioDirURL.path()) {
            XLog.info("Creating audio folder at \(audioDirURL)", source: "FileHelper")
            try fs.createDirectory(at: audioDirURL, withIntermediateDirectories: true)
        }
        
        let fileName = srcURL.lastPathComponent
        let destURL = fullAudioURL(for: fileName)
        
        XLog.info("Moving \(fileName) to audio folder", source: "FileHelper")
        try fs.moveItem(at: srcURL, to: destURL)
        
        return destURL
    }
    
    static func getAudioDuration(_ url: URL) async -> Double {
        let audioAsset = AVURLAsset.init(url: url, options: nil)
        do {
            let duration = try await audioAsset.load(.duration)
            return CMTimeGetSeconds(duration)
        } catch {
            XLog.error("Failed to get audio duration with \(error)", source: "FileHelper")
            return 0
        }
    }
    
    static func fullAudioURL(for fileName: String) -> URL {
        let audioDirURL = URL.documentsDirectory.appendingPathComponent(AUDIO_FOLDER)
        return audioDirURL.appending(path: fileName)
    }
}
