import UIKit
import XLog

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    
    lazy var showAdvancedOptions: Bool = {
        return false
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        #if SNAPSHOT
            setupSnapshotTestEnvironment()
        #endif
        
        if !showAdvancedOptions {
            Config.shared.transProvider = .apple
            Config.shared.sumEnabled = false
        }
        
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
