//
//  MemoEntity+Extension.swift
//  ALog
//
//  Created by Xin Du on 2023/07/10.
//

import Foundation
import CoreData
import XLog

extension MemoEntity {
    var viewContent: String {
        content ?? ""
    }
    
    var viewCreatedAt: String {
        let formatter = DateFormatter()
        if let timezone { formatter.timeZone = TimeZone(identifier: timezone) }
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: createdAt ?? Date())
    }
    
    var viewTime: String {
        let formatter = DateFormatter()
        if let timezone { formatter.timeZone = TimeZone(identifier: timezone) }
        formatter.dateFormat = "H:mm"
//        formatter.dateFormat = "h:mm a"
        return formatter.string(from: createdAt ?? Date())
    }
    
    
    /// 需要转写
    var needsTranscription: Bool {
        guard file != nil else { return false }
        
        if isFromWatch { return true }
        
        if Config.shared.transEnabled && Config.shared.autoSave && !transcribed {
            return true
        }
        
        return false
    }
}

extension MemoEntity {
    static var all: NSFetchRequest<MemoEntity> {
        let request = MemoEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \MemoEntity.day, ascending: false),
            NSSortDescriptor(keyPath: \MemoEntity.createdAt, ascending: false)
        ]
        return request
    }
    
    static func newEntity(moc: NSManagedObjectContext) -> MemoEntity {
        let memo = MemoEntity(context: moc)
        memo.id = UUID().uuidString.lowercased()
        memo.day = Int32(DateHelper.todayIdentifier())
        memo.timezone = TimeZone.current.identifier
        memo.createdAt = Date()
        return memo
    }
    
    static func delete(moc: NSManagedObjectContext, memo: MemoEntity) {
        if let file = memo.file {
            let url = FileHelper.fullAudioURL(for: file)
            do {
                XLog.debug("Deleting audio file at \(url.absoluteString)", source: "memo")
                try FileManager.default.removeItem(at: url)
            } catch {
                XLog.error(error, source: "memo")
            }
        }
        
        do {
            XLog.debug("Deleting memo \(memo.id ?? "")", source: "memo")
            moc.delete(memo)
            try moc.save()
        } catch {
            XLog.error(error, source: "memo")
        }
    }
}

#if DEBUG
extension MemoEntity {
    static func preview() -> MemoEntity {
        let ret =  MemoEntity.newEntity(moc: DataContainer.preview.context)
        ret.content = "I went to the movies today with my friends."
        ret.timezone = "Asia/Tokyo"
        ret.createdAt = Date()
        return ret
    }
}
#endif
