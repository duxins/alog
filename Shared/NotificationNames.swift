//
//  Notification+Extension.swift
//  ALog
//
//  Created by Xin Du on 2023/08/05.
//

import Foundation


extension Notification.Name {
    static let receivedFileFromWatch = Notification.Name("received_file_from_watch")
    static let recordingSentToIphone = Notification.Name("recording_sent_to_iphone")
    static let connectivityIsActive  = Notification.Name("connectivity_is_active")
}
