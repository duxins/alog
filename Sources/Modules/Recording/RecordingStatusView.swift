//
//  RecordingStatusView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/13.
//

import SwiftUI

struct RecordingStatusView: View {
    @State private var isRecording = false
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                Circle()
                    .fill(.red)
                    .frame(width: 12, height: 12)
                    .opacity(isRecording ? 1 : 0.4)
                Text(L(.recording).capitalized)
                    .font(.system(size: 20, weight: .bold))
            }
            .offset(x: -15)
            .animation(.linear(duration: 0.3).repeatForever(autoreverses: true), value: isRecording)
            Spacer()
        }
        .onAppear {
            isRecording = true
        }
    }
}

struct RecordingStatusView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingStatusView()
    }
}
