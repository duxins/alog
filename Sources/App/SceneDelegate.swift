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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.handleAutoStart()
        }
    }
    
    private func handleAutoStart() {
        if Config.shared.autoStartOnStartup == StartupOption.record {
            AppState.shared.startRecording()
        } else if Config.shared.autoStartOnStartup == StartupOption.createNote {
            AppState.shared.startCreatingNote()
        }
    }
}
