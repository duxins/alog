//
//  EditSummaryView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/22.
//

import SwiftUI

struct EditSummaryView: View {
    @ObservedObject var summary: SummaryEntity
    
    @State private var title = ""
    @State private var content = ""
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    init(summary: SummaryEntity) {
        self.summary = summary
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(L(.sum_title), text: $title)
                } header: {
                    Text(L(.sum_title))
                }
                
                Section {
                    MyTextView(text: $content, minHeight: 200)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text(L(.cancel))
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        save()
                        dismiss()
                    } label: {
                        Text(L(.save))
                    }
                    .disabled(title.isEmpty || content.isEmpty || (title == summary.viewTitle && content == summary.viewContent))
                }
            }
        }
        .onAppear {
            title = summary.viewTitle
            content = summary.viewContent
        }
    }
    
    private func save() {
        summary.title = title
        summary.content = content
        do {
            try moc.save()
        } catch {
        }
    }
}

#if DEBUG
struct EditSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        EditSummaryView(summary: SummaryEntity.preview())
    }
}
#endif
