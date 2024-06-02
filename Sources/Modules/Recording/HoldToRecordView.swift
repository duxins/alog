//
//  HoldToRecordView.swift
//  ALog
//
//  Created by Xin Du on 2024/06/02.
//

import SwiftUI

enum HoldToRecordState {
    case idle
    case recording
    case canceling
}

struct HoldToRecordView: View {
    @GestureState private var state: HoldToRecordState = .idle
    
    var onStart: () -> Void
    var onStop: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        ZStack {
            VStack {
                if isRecording {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                        .foregroundColor(state == .canceling ? .black : .app_btn_hold_cancel_xmark)
                        .padding()
                        .frame(width: 64, height: 64)
                        .background(state == .canceling ? .white : .app_btn_hold_cancel)
                        .clipShape(Circle())
                        .scaleEffect(state == .canceling ? 1.2 : 1)
                        .padding(.bottom, 50)
                }
                
                ZStack {
                    Circle()
                        .fill(.red.opacity(0.3))
                        .frame(width: 64, height: 64)
                        .scaleEffect(1.2)
                        .opacity(isRecording ? 1 : 0)
                    Image(systemName: "mic.fill")
                        .font(.system(size: 25))
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 64, height: 64)
                        .background(.red)
                        .clipShape(Circle())
                }
                .scaleEffect(isRecording ? 1.1 : 1)
            }
            
        }
        .gesture(
            LongPressGesture(minimumDuration: 0.2)
                .sequenced(before: DragGesture(minimumDistance: 0))
                .updating($state) { (value, state, _) in
                    switch value {
                    case .second(true, let drag):
                        if state == .idle {
                            start()
                            state = .recording
                        }
                        
                        if shouldCancelRecording(drag) {
                            if state != .canceling {
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            }
                            state = .canceling
                        } else {
                            state = .recording
                        }
                        
                    default:
                        break
                    }
                }
                .onEnded { value in
                    switch value {
                    case .first(true):
                        print("start")
                    case .second(true, let drag):
                        if shouldCancelRecording(drag) {
                            cancel()
                        } else {
                            stop()
                        }
                    default:
                        break
                    }
                }
        )
    }
    
    private var isRecording: Bool {
        state == .recording || state == .canceling
    }
    
    private func shouldCancelRecording(_ drag: DragGesture.Value?) -> Bool {
        guard let drag = drag else { return false }
        
        return drag.translation.height < -60
    }
    
    private func cancel() {
        onCancel()
    }
    
    private func start() {
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            onStart()
        }
    }
    
    private func stop() {
        onStop()
    }
}

#Preview {
    HoldToRecordView {
        print("hh")
    } onStop: {
        print("..")
    } onCancel: {
        print("..")
    }

}
