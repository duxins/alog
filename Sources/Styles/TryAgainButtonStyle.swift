//
//  TryAgainButtonStyle.swift
//  ALog
//
//  Created by Xin Du on 2023/07/22.
//

import SwiftUI

struct TryAgainButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.secondary)
            .background(Color(uiColor: .tertiarySystemFill))
            .opacity(configuration.isPressed ? 0.8 : 1)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
}

struct TryAgainButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button {
            
        } label: {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("Try Again")
            }
        }
        .buttonStyle(TryAgainButtonStyle())
        .preferredColorScheme(.dark)
    }
}
