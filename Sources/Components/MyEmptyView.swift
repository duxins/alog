//
//  EmptyView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/17.
//

import SwiftUI

struct MyEmptyView: View {
    let text: String
    var body: some View {
        ZStack {
            Color.clear
            VStack {
                Text(text)
                    .font(.title)
                    .fontWeight(.bold)
            }
            .offset(y: -80)
        }
    }
}


struct EmptyView_Previews: PreviewProvider {
    static var previews: some View {
        MyEmptyView(text: "No Memos")
    }
}
