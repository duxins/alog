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
    
    @State private var showStatus = false
    
    var body: some View {
        ZStack {
            Form {
                Section {
                    TextField(Constants.OpenAI.api_host, text: $vm.host)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
//                        .overlay {
//                            HStack {
//                                Spacer()
//                                if vm.isVerified {
//                                    Image(systemName: "checkmark.circle.fill")
//                                        .foregroundColor(.green)
//                                }
//                            }
//                        }
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
                        .opacity(vm.isVerified ? 1 : 0.5)
                        .animation(vm.isVerified ? .linear(duration: 0.4) : .none, value: vm.isVerified)
                    }
                    .disabled(!vm.isVerified)
                } footer: {
                    verifyingView()
                        .padding(.top, 20)
                        .opacity(showStatus ? 1 : 0)
                        .animation(.linear(duration: 0.14), value: showStatus)
                }
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
                        showStatus = true
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
    
    @ViewBuilder
    private func verifyingView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()
            ForEach(ServerVerificationItem.allCases, id: \.self) { item in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        Group {
                            statusView(vm.verificationItems[item]!)
                                .frame(width: 16, height: 16)
                            Text(item.displayName)
                                .foregroundColor(.secondary)
                        }
                        .font(.footnote)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    if case .failure(let err) = vm.verificationItems[item]! {
                        Text(err)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.leading, 26)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder
    private func statusView(_ status: ServerVerificationStatus) -> some View {
        switch status {
           case .pending: Circle().stroke(.secondary, style: .init(dash: [1, 2]))
           case .inProgress: ProgressView()
           case .success: Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
           case .failure: Image(systemName: "xmark.circle.fill").foregroundColor(.red)
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
