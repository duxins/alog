//
//  ServerSettingsView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/14.
//

import SwiftUI

struct ServerSettingsView: View {
    @EnvironmentObject var config: Config
    @StateObject private var vm = ServerSettingsViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section {
                TextField("", text: $vm.host)
                    .overlay {
                        HStack {
                            Spacer()
                            if vm.isVerified {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
            } header: {
                HStack {
                    Text(L(.settings_server_host))
                }
            }
            
            Section {
                MyToggle(isOn: $vm.requiresKey) {
                    Text(L(.settings_server_requires_key))
                }
                
                if vm.requiresKey {
                    TextField("sk-************************", text: $vm.key)
                        .font(.system(.footnote, design: .monospaced))
                        .foregroundColor(.secondary)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
            } header: {
                Text(L(.api_key))
            }
            
            Section {
                Button {
                    dismiss()
                    vm.save()
                } label: {
                    HStack {
                        HStack {
                            Text(L(.save))
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .animation(vm.isVerified ? .linear(duration: 0.3) : .none, value: vm.isVerified)
                }
                .disabled(!vm.isVerified)
            }
        }
        .navigationTitle(L(.settings_server_settings))
        .alert(L(.error), isPresented: $vm.showError) {
        } message: {
            Text(vm.lastErrorMessage)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                
                if vm.isVerifying {
                    ProgressView()
                } else {
                    Button {
                        vm.verify()
                        hideKeyboard()
                    } label: {
                        HStack(spacing: 10) {
                            Text(L(.verify))
                        }
                    }
                    .disabled(!vm.isServerValid)
                }
                
            }
        }
        .task {
            vm.load()
        }
    }
}

struct OpenAISettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ServerSettingsView()
            .preferredColorScheme(.dark)
            .environmentObject(Config.shared)
    }
}
