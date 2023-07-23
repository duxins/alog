//
//  DataContainer.swift
//  ALog
//
//  Created by Xin Du on 2023/07/10.
//

import Foundation
import CoreData
import XLog

class DataContainer: ObservableObject {
    let persistentContainer: NSPersistentContainer
    let context: NSManagedObjectContext
    
    static let shared = DataContainer()
    static let preview = DataContainer(inMemory: true)
    
    init(inMemory: Bool = false) {
        persistentContainer = NSPersistentContainer(name: "DataModel")
        
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        persistentContainer.loadPersistentStores { _, err in
            guard err == nil else {
                fatalError("Failed to load persistent store: \(err!.localizedDescription)")
            }
        }
        
        context = persistentContainer.viewContext
        
    }
}

extension DataContainer {
    func addMemo(content: String) {
        let memo = MemoEntity(context: context)
        memo.content = content
        memo.createdAt = Date()
        memo.timezone = TimeZone.current.identifier
        let day = dayIdentifier(Date())
        memo.day = day
        do {
            try context.save()
        } catch {
            XLog.error("failed to add memo with error: \(error.localizedDescription)")
        }
    }
    
    func deleteMemo(_ entity: MemoEntity) {
        context.delete(entity)
        do {
            try context.save()
        } catch {
            XLog.error("failed to delete memo with error: \(error.localizedDescription)")
        }
    }
    
    private func dayIdentifier(_ date: Date) -> Int32 {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyMMdd"
        let id = formatter.string(from: date)
        return Int32(id)!
    }
}
