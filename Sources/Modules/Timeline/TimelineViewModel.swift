//
//  TimelineViewModel.swift
//  ALog
//
//  Created by Xin Du on 2023/07/19.
//

import Foundation
import Combine
import XLog

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
