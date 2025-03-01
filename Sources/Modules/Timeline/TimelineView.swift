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
    @EnvironmentObject var config: Config
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
                if vm.isHoldingToRecord {
                    Color.black.opacity(0.8)
                }
                
                if !vm.isMultiSelectMode {
                    recordButton
                }
            }
            .background(Color.app_bg)
            .toolbar {
                toolbarContent
            }
            .navigationBarTitleDisplayMode(.inline)
            .task {
                appState.checkMicPermission()
            }
            .onDisappear {
                stopPlayer()
            }
            .alert(isPresented: $vm.showDeleteAlert) {
                Alert(title: Text(L(.are_you_sure)),
                      message: vm.isMultiSelectMode ? Text(L(.multi_delete_alert, vm.selectedMemos.count)) : nil,
                      primaryButton: .destructive(Text(L(.delete))) {
                        vm.deleteSelectedMemos(moc: moc)
                      }, secondaryButton: .cancel() {
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
            
            if days.isEmpty && !vm.isHoldingToRecord {
                VStack(spacing: 15) {
                    Group {
                        Text(config.holdToRecordEnabled ? L(.timeline_recbtn_hold_here) : L(.timeline_recbtn_tap_here))
                        Image(systemName: "arrow.down")
                    }
                    .font(.subheadline)
                }
                .foregroundColor(.secondary)
                .padding(.bottom, 15)
            }
            
            if !config.holdToRecordEnabled {
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
            } else {
                HoldToRecordView {
                    beginHoldToRecord()
                } onStop: {
                    endHoldToRecord()
                } onCancel: {
                    cancelHoldToRecord()
                }
            }
        }
        .padding(.bottom, 20)
    }
    
    private func startRecording() {
        appState.startRecording()
    }
    
    private func beginHoldToRecord() {
        guard appState.canStartRecording() else { return }
        vm.beginHoldToRecord()
    }
    
    private func endHoldToRecord() {
        vm.endHoldToRecord()
    }
    
    private func cancelHoldToRecord() {
        vm.cancelHoldToRecord()
    }
    
    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if vm.isMultiSelectMode {
            multiSelectToolbarItems
        } else {
            defaultToolbarItems
        }
    }

    @ToolbarContentBuilder
    private var defaultToolbarItems: some ToolbarContent {
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

    @ToolbarContentBuilder
    private var multiSelectToolbarItems: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                vm.isMultiSelectMode = false
                vm.selectedMemos.removeAll()
            } label: {
                Text(L(.cancel))
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                vm.showDeleteAlert = true
            } label: {
                Image(systemName: "trash")
            }
            .foregroundStyle(vm.selectedMemos.isEmpty ? Color.gray : Color.red)
            .disabled(vm.selectedMemos.isEmpty)
        }
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
