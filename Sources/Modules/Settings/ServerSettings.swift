//
//  ServerSettings.swift
//  ALog
//
//  Created by Xin Du on 2023/07/14.
//

import SwiftUI

struct ServerSettings: View {
    @EnvironmentObject var config: Config
    @StateObject private var vm = ServerSettingsViewModel()
    @FocusState private var keyIsFocused: Bool
    
    var body: some View {
        Form {
            Section {
                TextField("sk-************************", text: $config.apiKey)
                    .font(.system(.footnote, design: .monospaced))
                    .focused($keyIsFocused)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                if vm.isVerifying {
                    ProgressView()
                        .id(UUID())
                } else if vm.isKeyVerified {
                    Image(systemName: "checkmark.diamond.fill")
                        .foregroundColor(.green)
                } else {
                    Button {
                        vm.verify(config.apiKey)
                        dismissKeyboard()
                    } label: {
                        HStack(spacing: 10) {
                            Text(L(.verify))
                                .foregroundColor(config.isApiKeySet ? .blue : Color(uiColor: .tertiaryLabel))
                        }
                    }
                    .disabled(!config.isApiKeySet)
                }
                
            } header: {
                Text(L(.api_key))
            }
        }
        .navigationTitle(L(.settings_openai_settings))
        .alert("Error", isPresented: $vm.showError) {
        } message: {
            Text(vm.lastErrorMessage)
        }
    }
    
    private func dismissKeyboard() {
        keyIsFocused = false
    }
}

struct OpenAISettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ServerSettings()
            .preferredColorScheme(.dark)
            .environmentObject(Config.shared)
    }
}
