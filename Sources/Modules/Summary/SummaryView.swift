//
//  SummaryView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/17.
//

import SwiftUI

struct SummaryView: View {
    @FetchRequest<SummaryEntity>(sortDescriptors: [SortDescriptor(\.createdAt, order: .reverse)]) var items
    
    var body: some View {
        NavigationStack {
            ZStack {
                if items.isEmpty {
                    MyEmptyView(text: L(.summary_empty))
                } else {
                    ScrollView(.vertical) {
                        LazyVStack {
                            ForEach(items) { item in
                                NavigationLink(destination: SummaryDetailView(summary: item)) {
                                    SummaryEntryView(summary: item)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(L(.summary))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}
