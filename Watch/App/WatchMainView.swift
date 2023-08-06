//
//  WatchMainView.swift
//  ALogWatch
//
//  Created by Xin Du on 2023/08/05.
//

import SwiftUI

struct WatchMainView: View {
    var body: some View {
        TabView {
            WatchRecordView()
            WatchRecentsView()
        }
        .tabViewStyle(.page)
    }
}

struct WatchMainView_Previews: PreviewProvider {
    static var previews: some View {
        WatchMainView()
    }
}
