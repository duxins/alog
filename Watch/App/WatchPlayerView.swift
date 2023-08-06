//
//  WatchPlayerView.swift
//  ALogWatch
//
//  Created by Xin Du on 2023/08/06.
//

import SwiftUI

struct WatchPlayerView: View {
    let recording: RecordingEntity
    
    let circleWidth = 72.0
    let lineWidth = 5.0
    
    @Environment(\.dismiss) var dismiss
    @StateObject var player: AudioPlayer
    @State private var showingActionSheet = false
    @EnvironmentObject var dc: DataContainer
    
    
    init(recording: RecordingEntity) {
        self.recording = recording
        let url = FileHelper.fullAudioURL(for: recording.file!)
        self._player = StateObject(wrappedValue: AudioPlayer(url))
    }
    
    var body: some View {
        ZStack {
            Button {
                if player.isPlaying {
                    player.stop()
                    WKInterfaceDevice.current().play(.stop)
                } else {
                    WKInterfaceDevice.current().play(.start)
                    player.play()
                }
            } label: {
                Image(systemName: player.isPlaying ? "stop.fill" : "play.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            
            if player.isPlaying && player.duration > 0 {
                Group {
                    Circle()
                        .stroke(.white, lineWidth: lineWidth)
                        .frame(width: circleWidth)
                        .opacity(0.2)
                    Circle()
                        .trim(from: 0, to: player.timeElapsed / player.duration)
                        .stroke(.white, style: .init(lineWidth: lineWidth, lineCap: .round))
                        .frame(width: circleWidth)
                        .rotationEffect(.degrees(-90))
                        .animation(.default, value: player.timeElapsed)
                }
            }
        }
        .background(VolumeView().opacity(0))
        .confirmationDialog("", isPresented: $showingActionSheet) {
            Button(role: .destructive) {
                player.stop()
                dc.deleteRecording(recording)
                dismiss()
            } label: {
                Text(L(.delete))
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    player.stop()
                    dismiss()
                } label: {
                    Text(L(.cancel))
                        .foregroundColor(.secondary)
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    showingActionSheet = true
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
    }
}

