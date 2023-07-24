//
//  MainView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/10.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var container: DataContainer
    @EnvironmentObject var config: Config
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.activeTab) {
            TimelineView()
                .tabItem {
                    Image("tab_timeline")
                    Text(L(.timeline))
                }
                .tag(0)
                .toolbar(config.sumEnabled ? .visible : .hidden, for: .tabBar)
            
            SummaryView()
                .tabItem {
                    Image("tab_summary")
                    Text(L(.summary))
                }
                .tag(1)
        }
        .sheet(item: $appState.activeSheet) { item in
            switch item {
            case .settings:
                SettingsView()
            case .summarize(let item):
                AddSummaryPromptView(item: item)
                    .interactiveDismissDisabled()
            }
        }
    }
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AppState.shared)
    }
}
#endif
