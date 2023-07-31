//
//  DateController+Usage.swift
//  ALog
//
//  Created by Xin Du on 2023/07/31.
//

import Foundation
import CoreData
import XLog

extension DataContainer {
    func getTodayUsage() -> UsageEntity {
        let request = UsageEntity.fetchRequest()
        let day = DateHelper.todayIdentifier()
        request.predicate = NSPredicate(format: "day == %d", day)
        let usage: UsageEntity
        
        if let exist = try? context.fetch(request).first {
            usage = exist
        } else {
            usage = UsageEntity(context: context)
            usage.day = Int32(day)
        }
        return usage
    }
    
    func recordUsage(charsSent: Int = 0, charsReceived: Int = 0, whisper: Int = 0) {
        guard charsSent >= 0 && charsReceived >= 0 && whisper >= 0 else { return }
        
        XLog.debug("Record usage: sent: \(charsSent), received: \(charsReceived), whisper: \(whisper)", source: "Usage")
        
        let usage = getTodayUsage()
        usage.charsSent += Int32(charsSent)
        usage.charsReceived += Int32(charsReceived)
        usage.whisperDuration += Int32(whisper)
        try? context.save()
    }
}
