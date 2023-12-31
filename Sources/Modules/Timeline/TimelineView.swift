//
//  TimelineView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/10.
//

import SwiftUI
import StoreKit

struct TimelineView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var container: DataContainer
    @Environment(\.managedObjectContext) var moc
    @Environment(\.requestReview) var requestReview
    @SectionedFetchRequest(fetchRequest: MemoEntity.all, sectionIdentifier: \.day) var days
    @StateObject private var player = AudioPlayer.shared
    @StateObject private var vm = TimelineViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if days.isEmpty {
                    MyEmptyView(text: L(.timeline_empty))
                } else {
                    timelineList
                        .environmentObject(player)
                        .environmentObject(vm)
                }
                recordButton
            }
            .background(Color.app_bg)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        stopPlayer()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            appState.activeSheet = .settings
                        }
                    } label: {
                        Image("nav_settings")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            appState.activeSheet = .quickMemo
                        }
                    } label: {
                        Image("nav_quick_memo")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .task {
                appState.checkMicPermission()
            }
            .onDisappear {
                stopPlayer()
            }
            .alert(isPresented: $vm.showDeleteAlert) {
                Alert(title: Text(L(.are_you_sure)), primaryButton: .destructive(Text(L(.delete))) {
                    guard let item = vm.memoToDelete else { return }
                    MemoEntity.delete(moc: moc, memo: item)
                }, secondaryButton: .cancel() {
                    vm.memoToDelete = nil
                })
            }
            .onChange(of: vm.showReviewDialog) { newValue in
                guard newValue else { return }
                requestReview()
            }
        }
    }
    
    private func stopPlayer() {
        player.stop()
    }
    
    @ViewBuilder private var timelineList: some View {
        ScrollView {
            ScrollViewReader { scroll in
                LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                    ForEach(days) { day in
                        Section {
                            ForEach(day) { item in
                                TimelineEntryView(memo: item)
                                    .padding(.horizontal, 16)
                            }
                        } header: {
                            TimelineHeaderView(dayId: Int(day.id))
                        }
                    }
                    Spacer()
                        .frame(height: 90)
                }
            }
        }
    }
    
    @ViewBuilder private var recordButton: some View {
        VStack {
            Spacer()
            
            if days.isEmpty {
                VStack(spacing: 15) {
                    Group {
                        Text(L(.timeline_recbtn_tap_here))
                        Image(systemName: "arrow.down")
                    }
                    .font(.subheadline)
                }
                .foregroundColor(.secondary)
                .padding(.bottom, 15)
            }
            
            FeedbackButton(action: startRecording) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 25))
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 64, height: 64)
            }
            .background(.red)
            .clipShape(Circle())
            .accessibilityIdentifier("microphone")
        }
        .padding(.bottom, 20)
    }
    
    private func startRecording() {
        appState.startRecording()
    }
}

#if DEBUG
struct MemoListView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
            .environmentObject(AppState.shared)
            .environmentObject(DataContainer.shared)
    }
}
#endif
