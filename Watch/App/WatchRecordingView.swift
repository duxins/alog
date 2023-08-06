//
//  WatchRecordingView.swift
//  ALogWatch
//
//  Created by Xin Du on 2023/08/05.
//

import SwiftUI

struct WatchRecordingView: View {
    @ObservedObject var recorder: AudioRecorder
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: WatchAppState
    
    var body: some View {
        ZStack {
            if !recorder.isRecording {
                ProgressView()
            }
            
            recordedTimeLabel
                .opacity(recorder.isRecording ? 1 : 0)
                .offset(y: recorder.isRecording ? -20 : 0)
                .animation(.linear(duration: 0.25), value: recorder.isRecording)
            
            VStack {
                Spacer()
                
                Button {
                    WKInterfaceDevice.current().play(.stop)
                    recorder.stopRecording()
                    dismiss()
                } label: {
                    StopRecordingButton()
                }
                .buttonStyle(.plain)
                .opacity(recorder.isRecording ? 1 : 0)
                .animation(.easeIn(duration: 0.25).delay(0.25), value: recorder.isRecording)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    recorder.terminate()
                    dismiss()
                } label: {
                    Text(L(.cancel))
                        .foregroundColor(.secondary)
                }
            }
        }
        .task {
            recorder.startRecording()
        }
        .onChange(of: appState.micPermission) { newValue in
            if newValue == .denied {
                dismiss()
            }
        }
    }
    
    private var recordedTimeLabel: some View {
        Text(recorder.formattedTime)
            .font(.system(size: 36, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
    }
    
}

struct WatchRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        WatchRecordingView(recorder: AudioRecorder())
    }
}

struct StopRecordingButton: View {
    @State private var recording = false
    
    var body: some View {
        Image(systemName: "stop.fill")
            .font(.system(size: 24))
            .foregroundColor(Color.red)
            .frame(width: 50, height: 50)
            .background(
                Circle()
                    .fill(.red)
                    .scaleEffect(recording ? 0.94 : 1)
                    .opacity(recording ? 0.35 : 0.3)
            )
            .opacity(0.6)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: recording)
            .onAppear {
                self.recording = true
            }
    }
}
