//
//  RecordingCompletedView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/14.
//

import SwiftUI

struct RecordingCompletedView: View {
    @StateObject var vm: RecordingCompletedViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject var player: AudioPlayer
    
    @FocusState var focused
    
    @State private var showDeleteAlert = false
    
    init(voiceURL: URL) {
        self._vm = StateObject(wrappedValue: RecordingCompletedViewModel(voicePath: voiceURL))
        self._player = StateObject(wrappedValue: AudioPlayer(voiceURL))
    }
    
    var body: some View {
        ZStack {
            VStack {
                Form {
                    Section {
                        ZStack {
                            if vm.isTranscribing {
                                VStack(spacing: 15) {
                                    Text(L(.transcribing))
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    ProgressView()
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 100)
                            } else {
                                MyTextView(text: $vm.content, minHeight: 100)
                                    .disabled(vm.isTranscribing)
                                    .focused($focused)
                            }
                        }
                    } header: {
                        Text(L(.memo))
                    } footer: {
                        if let err = vm.transcriptionError {
                            Text(err)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                        }
                        
                        playerView()
                            .padding(.top, 30)
                    }
                }
                Spacer()
                VStack(spacing: 50) {
                    saveButton()
                }
                .padding(.horizontal, 30)
            }
        }
        .onChange(of: vm.saved) { newValue in
            dismiss()
        }
        .task {
            vm.transcribe()
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(title: Text(L(.are_you_sure)), primaryButton: .destructive(Text(L(.delete))) {
                vm.delete()
                dismiss()
            }, secondaryButton: .cancel())
        }
    }
    
    private func hideKeyboard() {
        focused = false
    }
    
    @ViewBuilder
    private func playerView() -> some View {
        VStack(spacing: 30) {
            HStack {
                Button {
                    hideKeyboard()
                    player.isPlaying ? player.stop() : player.play()
                } label: {
                    Image(systemName: player.isPlaying ? "stop.fill" : "play.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color(uiColor: .tertiarySystemFill), ignoresSafeAreaEdges: .init())
                        .clipShape(Circle())
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func saveButton() -> some View {
        VStack(spacing: 20) {
            HStack {
                FeedbackButton {
                    hideKeyboard()
                    withAnimation {
                        vm.save()
                    }
                } label: {
                    Text(L(.save).capitalized)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!vm.canBeSaved)
            }
            
            HStack {
                FeedbackButton(style: .heavy) {
                    hideKeyboard()
                    showDeleteAlert = true
                } label: {
                    HStack {
                        Group {
                            Image(systemName: "trash")
                        }
                    }
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .opacity(0.6)
            }
            Spacer().frame(height: 20)
        }
    }
}

#if DEBUG
struct RecordingCompletedView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingCompletedView(voiceURL: URL(filePath: "a.m4a"))
            .preferredColorScheme(.dark)
            .environmentObject(Config.shared)
        
    }
}
#endif
