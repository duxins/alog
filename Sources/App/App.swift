import SwiftUI

@main
struct ALogApp: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    let container = DataContainer.shared
    let appState = AppState.shared
    
    @StateObject var config = Config.shared
    @StateObject var iap = IAPManager()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .tint(Color.app_accent)
                .environmentObject(container)
                .environmentObject(appState)
                .environmentObject(config)
                .environmentObject(iap)
                .environment(\.managedObjectContext, container.context)
//                .preferredColorScheme(config.darkMode == .auto ? nil : (config.darkMode == .dark ? .dark : .light))
                .preferredColorScheme(.dark)
        }
    }
}
