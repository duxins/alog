//
//  QuickAction.swift
//  ALog
//
//  Created by Xin Du on 2024/05/11.
//

import UIKit

enum QuickAction: String {
    case record
    
    var shortcutItem: UIApplicationShortcutItem {
        switch self {
        case .record:
            .init(type: rawValue, localizedTitle: L(.start_recording), localizedSubtitle: "", icon: .init(systemImageName: "mic"))
        }
    }
    
    static func handle(_ item: UIApplicationShortcutItem) {
        guard let action = QuickAction(rawValue: item.type) else { return }
        switch action {
        case .record:
            AppState.shared.startRecording()
        }
    }
}
