//
//  TimelineEntryView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/12.
//

import SwiftUI
import CoreData

struct TimelineEntryView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var player: AudioPlayer
    @EnvironmentObject var vm: TimelineViewModel
    
    @ObservedObject var memo: MemoEntity
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 10) {
                timeLabel()
                contentLabel()
                if let file = memo.file {
                    HStack {
                        playButton(file)
                    }
                    .padding(.top, 8)
                }
            }
            menu()
                .offset(y: -8)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .quaternarySystemFill))
        )
        .padding(.bottom, 15)
        .contextMenu {
            if memo.viewContent.count > 0 { copyButton }
            editButton
            deleteButton
        }
    }
    
    @ViewBuilder
    private func timeLabel() -> some View {
        HStack {
            Text(memo.viewTime)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.app_timeline_time)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func contentLabel() -> some View {
        if vm.transcribingMemos.contains(memo) {
            Text(L(.transcribing))
                .foregroundColor(.secondary)
        } else {
            VStack(alignment: .leading, spacing: 10) {
                if memo.isHidden {
                    Text(memo.viewContent)
                        .redacted(reason: .placeholder)
                } else {
                    Text(memo.viewContent)
                        .foregroundColor(.app_timeline_text)
                }
                if let err = vm.failedMemos[memo] {
                    Text(err.localizedDescription)
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    @ViewBuilder
    private func menu() -> some View {
        if vm.transcribingMemos.contains(memo) {
            ProgressView()
        } else {
            Menu {
                transButton
                editButton
                if memo.viewContent.count > 0 { shareButton }
                if memo.file != nil { shareAudioButton }
                showHideButton
                deleteButton
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.app_timeline_time)
                    .frame(width: 30, height: 30)
            }
        }
    }
    
    @ViewBuilder
    private func playButton(_ file: String) -> some View {
        Button {
            if !player.isPlaying {
                player.play(file: file)
            } else {
                if file == player.currentFile {
                    player.stop()
                } else {
                    player.stop()
                    player.play(file: file)
                }
            }
        } label: {
            Image(systemName: player.isPlaying && file == player.currentFile ? "stop.fill" : "play.fill")
                .foregroundColor(player.isPlaying && file == player.currentFile ? .red : .secondary)
                .font(.system(size: 10))
                .frame(width: 24, height: 24)
                .background(Color(uiColor: .tertiarySystemFill))
                .clipShape(Circle())
                .animation(.none, value: player.isPlaying)
        }
    }
    
    @ViewBuilder
    private var deleteButton: some View {
        Button (role: .destructive) {
            vm.memoToDelete = memo
        } label: {
            Image(systemName: "trash")
            Text(L(.delete))
        }
    }
    
    @ViewBuilder
    private var editButton: some View {
        Button {
            appState.activeSheet = .editMemo(memo)
        } label: {
            Image(systemName: "square.and.pencil")
            Text(L(.edit))
        }
    }
    
    @ViewBuilder
    private var shareButton: some View {
        ShareLink(item: memo.viewContent) {
            Image(systemName: "square.and.arrow.up")
            Text(L(.share))
        }
    }
    
    @ViewBuilder
    private var shareAudioButton: some View {
        if let file = memo.file {
            ShareLink(item: FileHelper.fullAudioURL(for: file)) {
                Image(systemName: "waveform")
                Text(L(.share_audio))
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var copyButton: some View {
        Button {
            UIPasteboard.general.string = memo.viewContent
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            Image(systemName: "doc.on.doc")
            Text(L(.copy))
        }
    }
    
    private var transButton: some View {
        Button {
            vm.transcribe(memo)
        } label: {
            Image(systemName: "pencil.and.outline")
            if memo.transcribed {
                Text(L(.retranscribe))
            } else {
                Text(L(.transcribe))
            }
        }
    }
    
    private var showHideButton: some View {
        Button {
            vm.toggleVisibility(memo)
        } label: {
            if memo.isHidden {
                Image(systemName: "eye")
                Text(L(.show))
            } else {
                Image(systemName: "eye.slash")
                Text(L(.hide))
            }
        }
    }
}

#if DEBUG
struct TimelineEntryView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineEntryView(memo: MemoEntity.preview())
            .environment(\.managedObjectContext, DataContainer.shared.context)
            .preferredColorScheme(.dark)
            .environmentObject(AudioPlayer())
            .environmentObject(TimelineViewModel())
    }
}
#endif
