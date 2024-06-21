//
//  SceneDelegate.swift
//  ALog
//
//  Created by Xin Du on 2024/05/11.
//

import UIKit

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    @MainActor
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem) async -> Bool {
        QuickAction.handle(shortcutItem)
        return true
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        if Config.shared.autoRecordOnStartup {
            AppState.shared.startRecording()
        }
    }
}
