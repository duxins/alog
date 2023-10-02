//
//  Shortcuts.swift
//  ALog
//
//  Created by Xin Du on 2023/09/30.
//

import Foundation
import AppIntents

struct Shortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: StartRecordingIntent(), phrases: [], systemImageName: "mic.circle.fill")
    }
}
