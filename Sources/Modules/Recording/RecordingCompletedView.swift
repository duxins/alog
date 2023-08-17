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
    
    let editorMinHeight: CGFloat = 200.0
    
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
                                .frame(height: editorMinHeight)
                            } else {
                                MyTextView(text: $vm.content, minHeight: editorMinHeight)
                                    .disabled(vm.isTranscribing)
                            }
                        }
                    } header: {
                        Text(L(.memo))
                    } footer: {
                        VStack(spacing: 20) {
                            playerView()
                                .padding(.top, 20)
                            
                            if let err = vm.transcriptionError {
                                Text(err)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                Button {
                                    vm.transcriptionError = nil
                                    vm.transcribe()
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text(L(.try_again))
                                    }
                                }
                                .buttonStyle(TryAgainButtonStyle())
                            }
                        }
                    }
                }
            }
            
            VStack {
                Spacer()
                saveButton()
                
            }
            .padding(.horizontal, 30)
        }
        .onChange(of: vm.saved) { newValue in
            dismiss()
        }
        .task {
            if Config.shared.autoSave {
                vm.save()
                dismiss()
            } else {
                vm.transcribe()
            }
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(title: Text(L(.are_you_sure)), primaryButton: .destructive(Text(L(.delete))) {
                vm.delete()
                dismiss()
            }, secondaryButton: .cancel())
        }
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
        HStack(spacing: 20) {
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
            
            FeedbackButton(style: .heavy) {
                hideKeyboard()
                showDeleteAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(DestructiveButtonStyle())
            .frame(width: 40, height: 40)
        }
        .padding(.bottom, 30)
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
