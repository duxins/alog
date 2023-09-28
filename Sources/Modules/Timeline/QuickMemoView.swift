//
//  QuickMemoView.swift
//  ALog
//
//  Created by Xin Du on 2023/09/28.
//

import SwiftUI

struct QuickMemoView: View {
    
    @StateObject var vm = QuickMemoViewModel()
    @Environment(\.dismiss) var dismiss
    @FocusState private var focused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextEditor(text: $vm.content)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .frame(minHeight: 120)
                        .focused($focused)
                } header: {
                    Text(L(.memo))
                }
                Section {
                    Button {
                        vm.save()
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        dismiss()
                    } label: {
                        Text(L(.save))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(vm.content.count == 0)
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
            }
            .onAppear {
                focused = true
            }
        }
    }
}

#Preview {
    QuickMemoView()
}
