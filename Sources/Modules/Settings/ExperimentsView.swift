//
//  ExperimentsView.swift
//  ALog
//
//  Created by Xin Du on 2023/10/09.
//

import SwiftUI

struct ExperimentsView: View {
    @EnvironmentObject var config: Config
    
    
    var body: some View {
        Form {
            Section {
            }
        }
        .navigationTitle(L(.settings_experimental_features))
    }
}

struct ExperimentsView_Previews: PreviewProvider {
    static var previews: some View {
        ExperimentsView()
            .environmentObject(Config.shared)
    }
}
