//
//  Connectivity.swift
//  ALog
//
//  Created by Xin Du on 2023/08/04.
//

import Foundation
import WatchConnectivity
import XLog

class Connectivity: NSObject, ObservableObject {
    static let shared = Connectivity()
    private let TAG = "Conn"
    
    override private init() {
        super.init()
        XLog.debug("✓ Connectivity", source: "VM")
    }
    
    func activate() {
        #if os(iOS)
        guard WCSession.isSupported() else {
            XLog.info("WCSession is not supported", source: TAG)
            return
        }
        #endif
        XLog.debug("Activate WCSession", source: TAG)
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
}

extension Connectivity: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        #if os(watchOS)
        guard activationState == .activated else { return }
        NotificationCenter.default.post(name: .connectivityIsActive, object: nil)
        #endif
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        XLog.info("Session did become inactive", source: TAG)
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        XLog.info("Session did deactivate", source: TAG)
        WCSession.default.activate()
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        NotificationCenter.default.post(name: .receivedFileFromWatch, object: file)
    }
    #endif
    
    #if os(watchOS)
    func canSendFile() -> Bool {
        guard WCSession.default.activationState == .activated else {
            XLog.info("Activation state is not activated", source: TAG)
            return false
        }
        guard WCSession.default.isCompanionAppInstalled else {
            XLog.info("Companion app is not installed", source: TAG)
            return false
        }
        return true
    }
    
    func sendFile(_ url: URL, createdAt: Date, timezone: String = TimeZone.current.identifier) {
        guard canSendFile() else { return }
        WCSession.default.transferFile(url, metadata: [
            "timezone": timezone,
            "createdAt": createdAt
        ])
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        if error == nil {
            XLog.info("\(fileTransfer.file.fileURL.lastPathComponent) sent to iPhone successfully", source: "Conn")
            NotificationCenter.default.post(name: .recordingSentToIphone, object: fileTransfer)
        }
    }
    #endif
    
}
