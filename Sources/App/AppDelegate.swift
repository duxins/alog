import UIKit
import XLog

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    
    var timeSinceRelease: TimeInterval {
        AppInfo.releaseDate.timeIntervalSinceNow
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        #if SNAPSHOT
            setupSnapshotTestEnvironment()
        #endif
        
        #if DEBUG
        let loggerLevel = XLog.Level.debug
        #else
        let loggerLevel = XLog.Level.info
        #endif
        XLog.config(label: Bundle.main.bundleIdentifier!, level: loggerLevel)
        
        Connectivity.shared.activate()
        
        applyTheme()
        
        registerQuickActions()
        
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if let item = options.shortcutItem {
            QuickAction.handle(item)
        }
        let configuration = UISceneConfiguration(
           name: connectingSceneSession.configuration.name,
           sessionRole: connectingSceneSession.role
        )
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

extension AppDelegate {
    private func registerQuickActions() {
        UIApplication.shared.shortcutItems = [
            QuickAction.record.shortcutItem
        ]
    }
}

extension AppDelegate {
    private func applyTheme() {
        UITabBar.appearance().unselectedItemTintColor = UIColor(named: "tabbar_unselected")
        UITextView.appearance().backgroundColor = .clear
    }
}

