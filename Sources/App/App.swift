import SwiftUI

@main
struct ALogApp: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    let container = DataContainer.shared
    let appState = AppState.shared
    let config = Config.shared
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .tint(Color.app_accent)
                .preferredColorScheme(.dark)
                .environmentObject(container)
                .environmentObject(appState)
                .environmentObject(config)
                .environment(\.managedObjectContext, container.context)
        }
    }
}
