//
//  EditPromptViewModel.swift
//  ALog
//
//  Created by Xin Du on 2023/07/17.
//

import Foundation
import Combine
import XLog

class EditPromptViewModel: ObservableObject {
    
    let prompt: PromptEntity?
    let container = DataContainer.shared
    let moc = DataContainer.shared.context
    
    @Published var title = ""
    @Published var content = ""
    @Published var temperature = 0.5
    @Published var desc = ""
    @Published var canBeSaved = false
    @Published var newPrompt = false
    private var cancellables = Set<AnyCancellable>()
    
    init(prompt: PromptEntity? = nil) {
        self.prompt = prompt
        self.newPrompt = (prompt == nil)
        
        // update
        if let prompt {
            title = prompt.viewTitle
            content = prompt.viewContent
            temperature = prompt.temperature
            desc = prompt.viewDesc
        }
        
        Publishers.CombineLatest4($title, $content, $desc, $temperature)
            .sink { [unowned self] combine in
                var ret = !(combine.0.isEmpty || combine.1.isEmpty)
                if let prompt {
                    ret = ret && (combine.0 != prompt.viewTitle || combine.1 != prompt.viewContent || combine.2 != prompt.viewDesc || combine.3 != prompt.temperature)
                }
                canBeSaved = ret
            }
            .store(in: &cancellables)
        
    }
    
    func add() {
        let prompt =  PromptEntity.newEntity(moc: moc)
        updateAttributes(prompt)
        save()
    }
    
    func update() {
        guard let prompt else { return }
        updateAttributes(prompt)
        save()
    }
    
    func delete() {
        guard let prompt else { return }
        moc.delete(prompt)
        save()
    }
    
    private func updateAttributes(_ prompt: PromptEntity) {
        prompt.title = title
        prompt.desc = desc
        prompt.temperature = temperature
        prompt.content = content
    }
    
    private func save() {
        do {
            try moc.save()
        } catch {
            XLog.error(error.localizedDescription, source: "Prompt")
        }
    }
}
