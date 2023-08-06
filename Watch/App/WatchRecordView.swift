//
//  WatchRecordView.swift
//  ALogWatch
//
//  Created by Xin Du on 2023/08/04.
//

import SwiftUI
import XLog

struct WatchRecordView: View {
    @StateObject var recorder = AudioRecorder()
    @EnvironmentObject var dc: DataContainer
    @EnvironmentObject var appState: WatchAppState
    @EnvironmentObject var conn: Connectivity
    @EnvironmentObject var vm: WatchViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.watch_bg
                recordButton
            }.task {
                appState.checkMicPermission()
            }
            .alert(L(.watch_permission_title), isPresented: $vm.showPermissionAlert) {
            } message: {
                Text(L(.watch_permission_msg))
            }
            .onChange(of: recorder.isCompleted) { newValue in
                if newValue {
                    vm.saveFile(recorder.voiceFile!)
                }
                resetRecorder()
            }
            .fullScreenCover(isPresented: $vm.showRecordingView) {
                WatchRecordingView(recorder: recorder)
            }
        }
    }
    
    private var recordButton: some View {
        Button {
            startRecording()
        } label: {
            Circle()
                .fill(.red)
                .frame(width: 50)
                .padding()
                .background(Color.watch_rec_btn_border)
        }
        .clipShape(Circle())
        .buttonStyle(.borderless)
        .animation(.default, value: recorder.isRecording)
    }
    
    private func startRecording() {
        WKInterfaceDevice.current().play(.start)
        guard appState.micPermission != .denied else {
            vm.showPermissionAlert = true
            return
        }
        
        withoutAnimation {
            vm.showRecordingView = true
        }
    }
    
    private func resetRecorder() {
        recorder.isCompleted = false
    }
    
    private func withoutAnimation(action: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WatchRecordView()
            .environmentObject(WatchAppState.shared)
    }
}
