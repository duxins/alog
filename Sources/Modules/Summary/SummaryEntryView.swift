//
//  SummaryEntryView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/22.
//

import SwiftUI

struct SummaryEntryView: View {
    @ObservedObject var summary: SummaryEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(summary.viewTitle)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            Text(summary.truncatedContent(200))
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            
            Divider()
                .background(Color(uiColor: .tertiarySystemBackground))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 15)
    }
}

#if DEBUG
struct SummaryEntryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryEntryView(summary: SummaryEntity.preview())
            .preferredColorScheme(.dark)
    }
}
#endif
