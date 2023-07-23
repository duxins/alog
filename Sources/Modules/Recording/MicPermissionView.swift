//
//  MicPermissionView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/13.
//

import SwiftUI

struct MicPermissionView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    var denied: Bool {
        appState.micPermission == .denied
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
            VStack(spacing: 30) {
                Image(systemName: denied ? "mic.slash.fill" : "waveform.and.mic")
                    .font(.system(size: 50))
                    .foregroundColor(denied ? .red : .green)
                    .padding(.top, 50)
                
                VStack(spacing: 20) {
                    Group {
                        Text(L(.permission_mic_title))
                            .fontWeight(.bold)
                            .font(.system(size: 26))
                        if denied {
                            Text(L(.permission_mic_denied_msg))
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                        }
                    }
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
            }
            allowButton
        }
        .padding(.horizontal, 40)
        .presentationDetents([.large])
        .onChange(of: appState.micPermission) { v in
            if v != .denied {
                dismiss()
            }
        }
    }
    
    @ViewBuilder private var allowButton: some View {
        VStack {
            Spacer()
            VStack(spacing: 15) {
                Text(L(.permission_mic_msg))
                    .font(.caption2)
                    .foregroundColor(Color(uiColor: .tertiaryLabel))
                    .multilineTextAlignment(.center)
                Button {
                    if appState.micPermission == .denied {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    } else if appState.micPermission == .undetermined {
                        AudioRecorder.requestPermission()
                    }
                } label: {
                    Text(buttonTitle)
                        .fontWeight(.bold)
                        .padding(12)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    dismiss()
                } label: {
                    Text(L(.permission_not_now))
                        .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    var buttonTitle: String {
        switch appState.micPermission {
        case .undetermined: return L(.permission_allow)
        case .denied: return L(.permission_open_settings)
        default: return "-"
        }
    }
}

struct MicPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        MicPermissionView()
    }
}
