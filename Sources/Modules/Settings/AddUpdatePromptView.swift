//
//  AddPromptView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/17.
//

import SwiftUI

struct AddUpdatePromptView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm: EditPromptViewModel
    @State private var showDeleteAlert = false
    
    init(prompt: PromptEntity? = nil) {
        self._vm = StateObject(wrappedValue: EditPromptViewModel(prompt: prompt))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                titleSection
                descSection
                contentSection
                if !vm.newPrompt {
                    deleteButtonSection
                }
            }
            .navigationTitle(vm.newPrompt ? L(.settings_sum_prompts_add) : L(.settings_sum_prompts_edit))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text(L(.cancel))
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if vm.newPrompt {
                            vm.add()
                        } else {
                            vm.update()
                        }
                        dismiss()
                    } label: {
                        Text(L(.save))
                    }
                    .disabled(!vm.canBeSaved)
                }
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(title: Text(L(.are_you_sure)), primaryButton: .destructive(Text(L(.delete))) {
                    vm.delete()
                    dismiss()
                }, secondaryButton: .cancel())
            }
            .onAppear {
                if vm.newPrompt {
                    vm.content = L(.prompt_content_template)
                }
            }
        }
    }
    
    @ViewBuilder
    private var titleSection: some View {
        Section {
            TextField(L(.prompt_title), text: $vm.title)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            
        } header: {
            Text(L(.prompt_title))
        }
        
    }
    
    @ViewBuilder
    private var descSection: some View {
        Section {
            TextField(L(.optional), text: $vm.desc)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        } header: {
            Text(L(.prompt_desc))
        }
    }
    
    @ViewBuilder
    private var contentSection: some View {
        Section {
            ZStack(alignment: .topLeading) {
                if vm.content.isEmpty {
                    Text(L(.prompt_content))
                        .foregroundColor(Color(uiColor: .tertiaryLabel))
                        .padding(.top, 8)
                        .padding(.leading, 2)
                }
                MyTextView(text: $vm.content, minHeight: 200)
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        } header: {
            Text(L(.prompt_content))
        }
    }
    
    @ViewBuilder
    private var deleteButtonSection: some View {
        Section {
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Text(L(.delete))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct AddPromptView_Previews: PreviewProvider {
    static var previews: some View {
        AddUpdatePromptView()
            .preferredColorScheme(.dark)
    }
}
