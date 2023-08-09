import SwiftUI

@main
struct ALogApp: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    
    let container = DataContainer.shared
    let appState = AppState.shared
    let conn = Connectivity.shared
    
    @StateObject var config = Config.shared
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .tint(Color.app_accent)
                .environmentObject(container)
                .environmentObject(appState)
                .environmentObject(config)
                .environmentObject(conn)
                .environment(\.managedObjectContext, container.context)
                .preferredColorScheme(.dark)
        }
    }
}
