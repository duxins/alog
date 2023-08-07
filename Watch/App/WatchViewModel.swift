//
//  WatchViewModel.swift
//  ALogWatch
//
//  Created by Xin Du on 2023/08/05.
//

import Foundation
import XLog
import WatchConnectivity

class WatchViewModel: ObservableObject {
    let appState = WatchAppState.shared
    let dc = DataContainer.shared
    let conn = Connectivity.shared
    
    static let shared = WatchViewModel()
    
    @Published var showPermissionAlert = false
    @Published var showRecordingView = false
    
    private init() {
        XLog.debug("✓ WatchViewModel", source: "VM")
        NotificationCenter.default.addObserver(self, selector: #selector(didSendRecording), name: .recordingSentToIphone, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connectivityIsActive), name: .connectivityIsActive, object: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didSendRecording(_ notification: Notification) {
        guard let transfer = notification.object as? WCSessionFileTransfer else { return }
        let file = transfer.file.fileURL.lastPathComponent
        dc.markRecordingAsSent(file)
    }
    
    @objc func connectivityIsActive(_ notification: Notification) {
        let recs = dc.recordingsNotSent()
        for rec in recs {
            sendRecording(rec)
        }
    }
    
    private func sendRecording(_ rec: RecordingEntity) {
        guard let file = rec.file else { return }
        let url = FileHelper.fullAudioURL(for: file)
        conn.sendFile(url, createdAt: rec.viewCreatedAt, timezone: rec.viewTimeZone, duration: rec.duration)
    }
    
    func saveFile(_ url: URL, sync: Bool = true) {
        let rec = dc.newRecordingEntity()
        
        Task { @MainActor in
            do {
                let file = try FileHelper.moveAudioFile(url)
                let duration = await FileHelper.getAudioDuration(file)
                rec.file = file.lastPathComponent
                rec.duration = duration
                rec.sent = false
                try dc.context.save()
                
                guard sync else { return }
                
                guard conn.canSendFile() else {
                    XLog.debug("Can not send file to iPhone", source: "Conn")
                    return
                }
                
                sendRecording(rec)
            } catch {
                XLog.error(error, source: "File")
            }
        }
    }
}
