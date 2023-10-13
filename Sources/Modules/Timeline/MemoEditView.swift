//
//  MemoEditView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/19.
//

import SwiftUI

struct MemoEditView: View {
    @ObservedObject var memo: MemoEntity
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @State private var content: String = ""
    @State private var time = Date()
    
    @StateObject var player = AudioPlayer.shared
    
    init(memo: MemoEntity) {
        self.memo = memo
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    MyTextView(text: $content, minHeight: 120)
                } header: {
                    Text(L(.memo))
                }
                
                Section {
                    DatePicker(selection: $time, displayedComponents: [.date, .hourAndMinute]) {
                        Text("Time")
                    }
                    .tint(.gray)
                } footer: {
                    if memo.file != nil {
                        playerView()
                            .padding(.top, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text(L(.cancel))
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button() {
                        memo.content = content
                        memo.updateCreationTime(time)
                        try? moc.save()
                        dismiss()
                    } label: {
                        Text(L(.save))
                    }
                }
            }
        }
        .task {
            content = memo.viewContent
            time = memo.createdAt ?? Date()
            player.stop()
        }
    }
    
    @ViewBuilder
    private func playerView() -> some View {
        VStack(spacing: 30) {
            HStack {
                Button {
                    player.isPlaying ? player.stop() : player.play(file: memo.file!)
                } label: {
                    Image(systemName: player.isPlaying ? "stop.fill" : "play.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color(uiColor: .tertiarySystemFill))
                        .clipShape(Circle())
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

}

#if DEBUG
struct MemoEditView_Previews: PreviewProvider {
    static var previews: some View {
        MemoEditView(memo: MemoEntity.preview())
    }
}
#endif
