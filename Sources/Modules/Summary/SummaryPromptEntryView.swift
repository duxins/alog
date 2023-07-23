//
//  SummaryPromptEntryView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/21.
//

import SwiftUI

struct SummaryPromptEntryView: View {
    @ObservedObject var prompt: PromptEntity
    let selected: Bool
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(prompt.viewTitle)
                if prompt.viewDesc.count > 0 {
                    Text(prompt.viewDesc)
                        .font(.footnote)
                }
            }
            
            Spacer()
            
            if selected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .foregroundColor(textColor)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.app_bg.opacity(0.1))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor , lineWidth: borderWidth))
        .padding(.horizontal, 5)
    }
    
    private var textColor: Color {
        selected ? .primary : Color(uiColor: .tertiaryLabel)
    }
    
    private var borderColor: Color {
        selected ? .secondary : Color(uiColor: .quaternaryLabel)
    }
    
    private var borderWidth: CGFloat {
        selected ? 2 : 1
    }
}

#if DEBUG
struct SummaryPromptEntryView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SummaryPromptEntryView(prompt: PromptEntity.preview(), selected: false)
                .preferredColorScheme(.dark)
            
            SummaryPromptEntryView(prompt: PromptEntity.preview(), selected: true)
                .preferredColorScheme(.dark)
        }
    }
}
#endif
