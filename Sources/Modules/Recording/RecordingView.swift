//
//  RecordingView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/13.
//

import SwiftUI
import DSWaveformImage
import DSWaveformImageViews

struct RecordingView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @StateObject var recorder = AudioRecorder()
    
    @State private var showAutoStopTimer = false
    
    @State var configuration: Waveform.Configuration = .init(
        style: .striped(.init(color: .white.withAlphaComponent(0.5), width: 3, spacing: 3))
    )
    
    var body: some View {
        ZStack {
            if recorder.isRecording {
                closeButton
                RecordingStatusView()
                    .padding(.top, 30)
                recordedTimeLabel
                recordingButtons
            } else if recorder.isCompleted {
                RecordingCompletedView(voiceURL: recorder.voiceFile!)
                    .opacity(Config.shared.autoSave ? 0 : 1)
            } else {
                ProgressView()
            }
        }
        .task {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                recorder.startRecording()
            }
        }
        .onChange(of: appState.micPermission) { newValue in
            if newValue == .denied {
                dismiss()
            }
        }
        .onChange(of: recorder.isRecording) { newValue in
            UIApplication.shared.isIdleTimerDisabled = newValue
        }
    }
    
    @ViewBuilder
    var recordedTimeLabel: some View {
        Text(recorder.formattedTime)
            .font(.system(size: 50, weight: .bold, design: .monospaced))
            .offset(y: -80)
    }
    
    @ViewBuilder
    var recordingButtons: some View {
        VStack {
            Spacer()
            WaveformLiveCanvas(samples: recorder.samples, configuration: configuration)
                .frame(height: 50)
                .padding(.bottom, 40)
            
            // Buttons
            HStack {
                if Config.shared.featureAutoStop {
                    autoStopButton
                }
            }
            .frame(height: 50)
            .padding(.bottom, 20)
            
            StopRecordingButton {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                recorder.stopRecording()
            }
            Spacer()
                .frame(height: 100)
        }
    }
    
    @ViewBuilder
    var cancelTranscribingButton: some View {
        Button {
        } label: {
            Text(L(.cancel))
                .font(.headline)
        }.buttonStyle(SecondaryButtonStyle())
    }
    
    @ViewBuilder
    var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                FeedbackButton {
                    recorder.terminate()
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                }
                .foregroundColor(Color(uiColor: .tertiaryLabel))
                .padding(35)
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    /// 自动停止录音定时器
    private var autoStopButton: some View {
        Button {
            showAutoStopTimer = true
        } label: {
            VStack(spacing: 5) {
                Image(systemName: "stopwatch")
                    .foregroundColor(recorder.autoStopAt == nil ? .secondary : .primary)
                    .frame(height: 30)
                Text(recorder.formattedRemainingTime)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.red)
                    .opacity(0.8)
            }
        }
        .confirmationDialog(L(.auto_stop_dialog_title), isPresented: $showAutoStopTimer, titleVisibility: .visible) {
            Button(L(.auto_stop_dialog_off)) { autoStopAfter(nil) }
            Button(L(.auto_stop_dialog_minutes, "5"))  { autoStopAfter(5) }
            Button(L(.auto_stop_dialog_minutes, "10")) { autoStopAfter(10) }
            Button(L(.auto_stop_dialog_minutes, "20")) { autoStopAfter(20) }
            Button(L(.cancel), role: .cancel) { }
        }
    }
    
    private func autoStopAfter(_ m: Int?) {
        guard let m = m else {
            recorder.autoStopAt = nil
            return
        }
        recorder.autoStopAt = recorder.recordedTime + m * 60
    }
}


struct StopRecordingButton: View {
    @State private var recording = false
    var action: () -> Void
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button (action: action) {
            Image(systemName: "stop.fill")
                .font(.system(size: 30))
                .foregroundColor(.red)
                .padding()
                .background(.white)
                .clipShape(Circle())
        }
        .padding(8)
        .background(
            Color(uiColor: .tertiaryLabel)
                .opacity(recording ? 1 : 0.6)
        )
        .clipShape(Circle())
        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: recording)
        .onAppear {
            self.recording = true
        }
    }
}

struct RecordingView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingView()
            .preferredColorScheme(.dark)
            .environmentObject(AppState.shared)
    }
}
