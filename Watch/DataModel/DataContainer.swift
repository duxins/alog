//
//  DataContainer.swift
//  ALogWatch
//
//  Created by Xin Du on 2023/08/05.
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
        persistentContainer = NSPersistentContainer(name: "WatchDataModel")
        
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
    func newRecordingEntity() -> RecordingEntity {
        let ret = RecordingEntity(context: context)
        ret.timezone = TimeZone.current.identifier
        ret.createdAt = Date()
        return ret
    }
    
    func markRecordingAsSent(_ file: String) {
        let request = RecordingEntity.fetchRequest()
        request.predicate = NSPredicate(format: "file == %@", file)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            guard let rec = results.first else { return }
            rec.sent = true
            try context.save()
        } catch {
            XLog.error(error, source: "DC")
        }
    }
    
    func deleteRecording(_ recording: RecordingEntity) {
        do {
            XLog.debug("Delete recording \(recording.viewTitle)", source: "DC")
            context.delete(recording)
            try context.save()
            if let fileName = recording.file {
                let url = FileHelper.fullAudioURL(for: fileName)
                XLog.debug("Delete \(fileName)", source: "DC")
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            XLog.error(error, source: "DC")
        }
    }
    
    func recordingsNotSent() -> [RecordingEntity] {
        let request = RecordingEntity.fetchRequest()
        request.predicate = NSPredicate(format: "sent == false")
        do {
            let results = try context.fetch(request)
            return results
        } catch {
            XLog.error(error, source: "DC")
        }
        return []
    }
}
