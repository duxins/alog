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
            } footer: {
                footerView
                    .padding(.top, 40)
            }
        }
        .navigationTitle(L(.settings_openai_settings))
        .alert("Error", isPresented: $vm.showError) {
        } message: {
            Text(vm.lastErrorMessage)
        }
    }
    
    @ViewBuilder
    private var footerView: some View {
        HStack {
            Button {
                UIApplication.shared.open(URL(string: Constants.OpenAI.api_key_url)!)
            } label: {
                Group {
                    Text(L(.settings_openai_settings_key_method)) +
                    Text("\n" + Constants.OpenAI.api_key_url.replacingOccurrences(of: "https://", with: ""))
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.blue)
                }
                .foregroundColor(.secondary)
                .font(.callout)
                .opacity(0.8)
            }
        }
        .frame(maxWidth: .infinity)
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
