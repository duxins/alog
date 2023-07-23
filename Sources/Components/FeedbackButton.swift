//
//  FeedbackButton.swift
//  ALog
//
//  Created by Xin Du on 2023/07/18.
//

import SwiftUI

struct FeedbackButton<Label: View>: View {
    let style: UIImpactFeedbackGenerator.FeedbackStyle
    
    let action: () -> Void
    let label: Label
    
    init(style: UIImpactFeedbackGenerator.FeedbackStyle = .rigid, action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.style = style
        self.action = action
        self.label = label()
    }
    
    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: style).impactOccurred()
            action()
        } label: {
            label
        }
    }
}

struct FeedbackButton_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackButton {
            print("hello")
        } label: {
            Image(systemName: "trash")
        }

    }
}
