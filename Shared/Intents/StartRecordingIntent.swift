//
//  StartRecordingIntent.swift
//  ALog
//
//  Created by Xin Du on 2023/09/30.
//

import Foundation
import AppIntents

struct StartRecordingIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource(stringLiteral: "start_recording")

    @MainActor
    func perform() async throws -> some IntentResult {
        #if os(iOS)
            AppState.shared.startRecording()
        #else
            WatchAppState.shared.startRecording()
        #endif
        return .result()
    }
  
    static var openAppWhenRun: Bool = true
}
