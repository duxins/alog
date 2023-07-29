import UIKit
import XLog

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    
    var timeSinceRelease: TimeInterval {
        AppInfo.releaseDate.timeIntervalSinceNow
    }
    
    lazy var showAdvancedOptions: Bool = {
        #if SNAPSHOT
        return false
        #else
        return true
        #endif
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
