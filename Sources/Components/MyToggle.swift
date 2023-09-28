//
//  MyToggle.swift
//  ALog
//
//  Created by Xin Du on 2023/07/14.
//

import SwiftUI

struct MyToggle<Label: View>: View {
    @EnvironmentObject var appState: AppState
    @Binding var isOn: Bool
    
    let label: () -> Label
    
    init(isOn: Binding<Bool>,  @ViewBuilder label: @escaping () -> Label) {
        self._isOn = isOn
        self.label = label
    }
    
    var body: some View {
        Toggle(isOn: $isOn, label: label)
            .tint(.green)
    }
}

struct MyToggle_Previews: PreviewProvider {
    static var previews: some View {
        MyToggle(isOn: .constant(true)) {
            Text("hello")
        }
    }
}
