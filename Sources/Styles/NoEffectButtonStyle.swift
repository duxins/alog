//
//  NoEffectButtonStyle.swift
//  ALog
//
//  Created by Xin Du on 2023/07/22.
//

import SwiftUI

struct NoEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct NoEffectButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button {
            
        } label: {
            Image(systemName: "plus")
                .background(.red)
        }.buttonStyle(NoEffectButtonStyle())
    }
}
