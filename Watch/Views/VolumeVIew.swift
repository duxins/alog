//
//  VolumeVIew.swift
//  ALog
//
//  Created by Xin Du on 2023/08/06.
//

import SwiftUI
import WatchKit

// Take from https://stackoverflow.com/questions/58539883/controlling-volume-of-apple-watch
struct VolumeView: WKInterfaceObjectRepresentable {
    typealias WKInterfaceObjectType = WKInterfaceVolumeControl

    func makeWKInterfaceObject(context: Self.Context) -> WKInterfaceVolumeControl {
        let view = WKInterfaceVolumeControl(origin: .local)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak view] timer in
            if let view = view {
                view.focus()
            } else {
                timer.invalidate()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            view.resignFocus()
            view.focus()
        }
        return view
    }
    
    func updateWKInterfaceObject(_ wkInterfaceObject: WKInterfaceVolumeControl, context: WKInterfaceObjectRepresentableContext<VolumeView>) {
    }
}
