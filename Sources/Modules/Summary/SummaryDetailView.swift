//
//  SummaryDetailView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/22.
//

import SwiftUI

struct SummaryDetailView: View {
    @ObservedObject var summary: SummaryEntity
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Text(summary.viewContent)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
            .toolbar {
                ToolbarItem {
                    Menu {
                        ShareLink(item: summary.shareContent) {
                            Image(systemName: "square.and.arrow.up")
                            Text(L(.share))
                        }
                        
                        Button {
                            appState.activeSheet = .editSummary(summary)
                        } label: {
                            Image(systemName: "square.and.pencil")
                            Text(L(.edit))
                        }
                        
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Image(systemName: "trash")
                            Text(L(.delete))
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(title: Text(L(.are_you_sure)), primaryButton: .destructive(Text(L(.delete))) {
                    moc.delete(summary)
                    try? moc.save()
                    dismiss()
                }, secondaryButton: .cancel())
            }
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle(summary.viewTitle)
    }
}

#if DEBUG
struct SummaryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryDetailView(summary: SummaryEntity.preview())
            .preferredColorScheme(.dark)
            .environment(\.managedObjectContext, DataContainer.preview.context)
    }
}
#endif
