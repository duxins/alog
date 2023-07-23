//
//  SummaryEntity+Extension.swift
//  ALog
//
//  Created by Xin Du on 2023/07/22.
//

import Foundation
import CoreData
import XLog

extension SummaryEntity {
    var viewTitle: String {
        title ?? ""
    }
    
    var viewContent: String {
        content ?? ""
    }
    
    var shareContent: String {
        "# \(viewTitle)" + "\n\n" + viewContent
    }
    
    func truncatedContent(_ length: Int) -> String {
        guard let content = content else { return "" }
        let ret = content.prefix(length)
        if content.count > length {
            return ret + "..."
        }
        return String(ret)
    }
}

extension SummaryEntity {
    static func newEntity(moc: NSManagedObjectContext) -> SummaryEntity {
        let ret = SummaryEntity(context: moc)
        ret.id = UUID().uuidString.lowercased()
        ret.timezone = TimeZone.current.identifier
        ret.createdAt = Date()
        return ret
    }
}

#if DEBUG
extension SummaryEntity {
    static func preview() -> SummaryEntity {
        let ret =  SummaryEntity.newEntity(moc: DataContainer.preview.context)
        ret.title = "2023/07/22"
        ret.content = "It was a great to walk down memory lane."
        ret.timezone = "Asia/Tokyo"
        ret.createdAt = Date()
        return ret
    }
}
#endif
