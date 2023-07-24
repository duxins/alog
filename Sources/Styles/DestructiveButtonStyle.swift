//
//  DestructiveButtonStyle.swift
//  ALog
//
//  Created by Xin Du on 2023/07/24.
//

import SwiftUI

struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .foregroundColor(.white)
            .background(Color(uiColor: .systemRed))
            .cornerRadius(14)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

struct DestructiveButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button {
        } label: {
            Image(systemName: "trash")
        }
        .buttonStyle( DestructiveButtonStyle() )
    }
}
