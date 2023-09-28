//
//  QuickMemoViewModel.swift
//  ALog
//
//  Created by Xin Du on 2023/09/28.
//

import Foundation
import XLog

class QuickMemoViewModel: ObservableObject {
    
    @Published var content: String = ""
    
    func save() {
        let moc = DataContainer.shared.context
        let memo = MemoEntity.newEntity(moc: moc)
        memo.content = content
        do {
            try moc.save()
        } catch {
            XLog.error(error, source: "memo")
        }
    }
}
