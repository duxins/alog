//
//  TimelineViewModel.swift
//  ALog
//
//  Created by Xin Du on 2023/07/19.
//

import Foundation

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
}
