//
//  RecordingCompletedViewModel.swift
//  ALog
//
//  Created by Xin Du on 2023/07/15.
//

import Foundation
import CoreData
import XLog

class RecordingCompletedViewModel: ObservableObject {
    var voiceURL: URL
    let container = DataContainer.shared
    let moc: NSManagedObjectContext
    let config = Config.shared
    let trans = Transcription()
    
    @Published var hasTranscribed = false
    @Published var isTranscribing = false
    @Published var transcribedText: String? {
        didSet {
            hasTranscribed = true
            content = transcribedText ?? ""
        }
    }
    
    @Published var transcriptionError: String?
    @Published var saved = false
    @Published var content = ""
    @Published var duration: Double = 0
    @Published var canBeSaved: Bool = false
    
    init(voicePath: URL) {
        self.voiceURL = voicePath
        moc = container.context
        
        Task { @MainActor in
            duration = await FileHelper.getAudioDuration(voiceURL)
            canBeSaved = true
        }
    }
    
    deinit {
        #if DEBUG
            XLog.debug("✖︎ RecordingCompletedViewModel", source: "Recording")
        #endif
    }
    
    func transcribe() {
        guard config.transEnabled else { return }
        guard isTranscribing == false else { return }
        
        Task { @MainActor in
            isTranscribing = true
            do {
                let txt = try await trans.transcribe(voiceURL: voiceURL, provider: config.transProvider, lang: config.transLang)
                transcribedText = txt
            } catch {
                transcriptionError = ErrorHelper.desc(error)
            }
            isTranscribing = false
        }
    }
    
    func save() {
        let memo = MemoEntity.newEntity(moc: moc)
        memo.file = voiceURL.lastPathComponent
        memo.content = content
        memo.transcribed = hasTranscribed
        memo.duration = duration
        do {
            try moc.save()
            _ = try FileHelper.moveAudioFile(voiceURL)
            saved = true
        } catch {
            XLog.error(error, source: "recording")
        }
    }
    
    func delete() {
        do {
            XLog.debug("Deleting temporary audio file at \(voiceURL.absoluteString)", source: "recording")
            try FileManager.default.removeItem(at: voiceURL)
        } catch {
            XLog.error(error, source: "recording")
        }
    }
}
