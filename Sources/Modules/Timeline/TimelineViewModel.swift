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

class TimelineViewModel: ObservableObject {
    @Published var showDeleteAlert = false
    @Published var memoToDelete: MemoEntity? {
        didSet {
            if memoToDelete != nil {
                showDeleteAlert = true
            }
        }
    }
    @Published var memoToEdit: MemoEntity?
    @Published var memoToShare: MemoEntity?
    
    @Published var transcribingMemos = Set<MemoEntity>()
    @Published var failedMemos = [MemoEntity: Error]()
    
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
                guard memo.isFromWatch else { continue }
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
                }
            case .failure(let error):
                self?.failedMemos[memo] = error
                XLog.error(error, source: "Timeline")
            }
        }
    }
    
}
