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
                        .foregroundColor(textColor.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if selected {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
            }
        }
        .foregroundColor(textColor)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(bgColor)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: borderWidth)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 5)
    }
    
    private var bgColor: Color {
        selected ? Color(uiColor: .tertiarySystemBackground)
            .opacity(0.2)
        : Color(uiColor: .tertiarySystemBackground).opacity(0.1)
    }
    
    private var textColor: Color {
        selected ? .primary : .primary.opacity(0.3)
    }
    
    private var borderColor: Color {
        selected ? .primary.opacity(0.8) : .primary.opacity(0.1)
    }
    
    private var borderWidth: CGFloat {
        selected ? 1 : 1
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
