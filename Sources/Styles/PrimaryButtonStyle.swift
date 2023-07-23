//
//  PrimaryButtonStyle.swift
//  ALog
//
//  Created by Xin Du on 2023/07/14.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.bold)
            .frame(height: 50)
            .background(bgColor(isPressed: configuration.isPressed))
            .foregroundColor(color(isPressed: configuration.isPressed))
            .cornerRadius(14)
    }
    
    private func color(isPressed: Bool) -> Color {
        if !isEnabled {
            return Color.app_primary_btn_text_disabled
        }
        return Color.app_primary_btn_text
    }
    
    private func bgColor(isPressed: Bool) -> Color {
        return isPressed ? Color.app_primary_btn_bg_pressed : Color.app_primary_btn_bg
    }
}
    
struct PrimaryButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button {
            
        } label: {
            Text("保存")
                .font(.headline)
        }
        .buttonStyle(PrimaryButtonStyle())
        .preferredColorScheme(.dark)
        .disabled(true)
    }
}
