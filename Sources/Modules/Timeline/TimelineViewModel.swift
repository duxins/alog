//
//  TimelineViewModel.swift
//  ALog
//
//  Created by Xin Du on 2023/07/19.
//

import Foundation
import Combine
import XLog
import CoreData
import SwiftUI

class TimelineViewModel: ObservableObject {
    @Published var showDeleteAlert = false
    @Published var memoToDelete: MemoEntity? {
        didSet {
            if memoToDelete != nil {
                showDeleteAlert = true
            }
        }
    }
    @Published var memoToShare: MemoEntity?
    
    @Published var transcribingMemos = Set<MemoEntity>()
    @Published var failedMemos = [MemoEntity: Error]()
    @Published var showReviewDialog = false
    
    @Published var isHoldingToRecord = false
    
    let recorder = AudioRecorder()
    
    @AppStorage("requested_review_at") var requestedReviewAt = Date(timeIntervalSince1970: 0).timeIntervalSince1970
    
    private var transCount = 0
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave), name: .NSManagedObjectContextDidSave, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func contextDidSave(notification: Notification) {
        guard Config.shared.transEnabled else { return }
        guard let userInfo = notification.userInfo else { return }
        if let insertedObjects = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, !insertedObjects.isEmpty {
            for obj in insertedObjects {
                guard let memo = obj as? MemoEntity else { continue }
                guard memo.needsTranscription else { continue }
                transcribe(memo)
            }
        }
    }
    
    func transcribe(_ memo: MemoEntity) {
        guard memo.file != nil else { return }
        failedMemos[memo] = nil
        transcribingMemos.insert(memo)
        Transcription.shared.transcribe(memo) { [weak self] result in
            self?.transcribingMemos.remove(memo)
            switch result {
            case .success(let text):
                if memo.content != text {
                    memo.content = text
                    memo.transcribed = true
                    try? DataContainer.shared.context.save()
                    self?.transCount += 1
                    self?.requestReview()
                }
            case .failure(let error):
                self?.failedMemos[memo] = error
                XLog.error(error, source: "Timeline")
            }
        }
    }
    
    func toggleVisibility(_ memo: MemoEntity) {
        memo.isHidden.toggle()
        do {
            try DataContainer.shared.context.save()
        } catch {
            XLog.error(error, source: "Timeline")
        }
    }
    
    private func requestReview() {
        guard transCount > 5 else { return }
        let timeInterval = Date().timeIntervalSince1970
        if timeInterval - requestedReviewAt > 3600 * 24 * 10 {
            showReviewDialog = true
            requestedReviewAt = timeInterval
        }
    }
    
    
    func beginHoldToRecord() {
        recorder.startRecording()
        isHoldingToRecord = true
    }
    
    func endHoldToRecord() {
        isHoldingToRecord = false
        recorder.didCompleteCallback = { [weak self] in
            guard let self = self, let url = self.recorder.voiceFile else {
                return
            }
            self.saveVoice(url)
        }
        recorder.stopRecording()
    }
    
    func cancelHoldToRecord() {
        recorder.terminate()
        isHoldingToRecord = false
    }
    
    private func saveVoice(_ voiceURL: URL) {
        guard let voiceURL = recorder.voiceFile else { return }
        let moc = DataContainer.shared.context
        let memo = MemoEntity.newEntity(moc: moc)
        memo.file = voiceURL.lastPathComponent
        do {
            try moc.save()
            _ = try FileHelper.moveAudioFile(voiceURL)
        } catch {
            XLog.error(error, source: "recording")
        }
    }
    
}
