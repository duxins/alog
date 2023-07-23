import UIKit
import XLog

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        #if DEBUG
        if CommandLine.arguments.contains("--SnapshotTesting") {
            setupSnapshotTestEnvironment()
        }
        #endif
        
        #if DEBUG
        let loggerLevel = XLog.Level.debug
        #else
        let loggerLevel = XLog.Level.info
        #endif
        XLog.config(label: Bundle.main.bundleIdentifier!, level: loggerLevel)
        applyTheme()
        return true
    }
}

private func applyTheme() {
    UITabBar.appearance().unselectedItemTintColor = UIColor(named: "tabbar_unselected")
    UITextView.appearance().backgroundColor = .clear
}
