//
//  WatchApp.swift
//  ALogWatch
//
//  Created by Xin Du on 2023/08/04.
//

import SwiftUI
import XLog

@main
struct ALogWatchApp: App {
    @WKApplicationDelegateAdaptor var delegate: WatchAppDelegate
    
    @StateObject var container = DataContainer.shared
    @StateObject var appState = WatchAppState.shared
    
    let vm: WatchViewModel
    let conn: Connectivity
    
    init() {
        #if DEBUG
        let loggerLevel = XLog.Level.debug
        #else
        let loggerLevel = XLog.Level.info
        #endif
        XLog.config(label: Bundle.main.bundleIdentifier!, level: loggerLevel)
        
        conn = Connectivity.shared
        vm = WatchViewModel.shared
        
        conn.activate()
    }
    
    var body: some Scene {
        WindowGroup {
            WatchMainView()
                .environmentObject(vm)
                .environmentObject(conn)
                .environmentObject(appState)
                .environmentObject(container)
                .environment(\.managedObjectContext, container.context)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    appState.openURL(url)
                }
        }
    }
}
