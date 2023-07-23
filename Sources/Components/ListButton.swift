//
//  ListButton.swift
//  ALog
//
//  Created by Xin Du on 2023/07/10.
//

import SwiftUI

struct ListButton<Content: View, Detail: View>: View {
    let action: () -> Void
    let detail: Detail
    let content: Content
    
    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content, @ViewBuilder detail: () -> Detail) {
        self.action = action
        self.content = content()
        self.detail = detail()
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                content
                    .foregroundColor(.primary)
                Spacer()
                    HStack {
                        detail
                        Image(systemName: "chevron.right")
                            .font(.callout)
                    }
                    .foregroundColor(.gray)
            }
        }
    }
}

struct ListButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ListButton {
                
            } content: {
                Text("API KEY")
            } detail: {
                Text("未设置")
            }
        }
        .padding()
    }
}
