//
//  Exporter.swift
//  ALog
//
//  Created by Xin Du on 2023/07/22.
//

import Foundation
import CoreData
import XLog

class Exporter {
    
    enum Format {
        case markdown
    }
    
    static func exportMemos(_ dayId: Int, moc: NSManagedObjectContext, format: Format = .markdown) -> String {
        let fetchRequest = MemoEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "day = %d", dayId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \MemoEntity.createdAt, ascending: true)]
        
        var ret = "# \(DateHelper.formatIdentifier(dayId))\n\n"
        do {
            let memos = try moc.fetch(fetchRequest).filter { !$0.viewContent.isEmpty }
            for memo in memos {
                ret.append("## \(memo.viewTime)\n\n")
                ret.append(memo.viewContent)
                ret.append("\n\n")
            }
        } catch {
            XLog.error(error, source: "Export")
        }
        return ret
    }
}
