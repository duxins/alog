//
//  PromptEntity+Extension.swift
//  ALog
//
//  Created by Xin Du on 2023/07/17.
//

import CoreData

extension PromptEntity {
    var viewTitle: String {
        title ?? ""
    }
    
    var viewContent: String {
        content ?? ""
    }
    
    var viewDesc: String {
        desc ?? ""
    }
}

extension PromptEntity {
    static func newEntity(moc: NSManagedObjectContext) -> PromptEntity {
        let obj = PromptEntity(context: moc)
        obj.createdAt = Date()
        return obj
    }
}

#if DEBUG
extension PromptEntity {
    static func preview() -> PromptEntity {
        let ret =  PromptEntity.newEntity(moc: DataContainer.preview.context)
        ret.title = "Default"
        ret.desc = "Generate a summary of diary."
        ret.content = "........"
        return ret
    }
}
#endif
