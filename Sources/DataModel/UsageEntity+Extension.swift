//
//  UsageEntity+Extension.swift
//  ALog
//
//  Created by Xin Du on 2023/07/31.
//

import Foundation
import CoreData

extension UsageEntity {
    
    var viewDay: Int {
        if day == 0 {
            return DateHelper.todayIdentifier()
        }
        return Int(day)
    }
    
    var viewCharsSent: Int {
        Int(charsSent)
    }
    
    var viewCharsReceived: Int {
        Int(charsReceived)
    }
    
    var viewWisperDuration: Int {
        Int(whisperDuration)
    }
    
    var viewCharsTotal: Int {
        Int(charsSent + charsReceived)
    }
    
}

