//
//  RecordingEntity+Extension.swift
//  ALogWatch
//
//  Created by Xin Du on 2023/08/06.
//

import Foundation
import CoreData

extension RecordingEntity {
    var viewCreatedAt: Date {
        createdAt ?? Date()
    }
    
    var viewTimeZone: String {
        timezone ?? TimeZone.current.identifier
    }
    
    var viewTitle: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: viewTimeZone)
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: createdAt ?? Date())
    }
    
    var viewLength: String {
        return String(format: "%02d:%02d", Int(duration) / 60, Int(duration) % 60)
    }
}

extension RecordingEntity {
    static var recentTen: NSFetchRequest<RecordingEntity> {
        let request = RecordingEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \RecordingEntity.createdAt, ascending: false)]
        request.fetchLimit = 10
        return request
    }
}
