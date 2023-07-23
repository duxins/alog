//
//  AddSummaryPromptView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/20.
//

import SwiftUI
import CoreData

struct AddSummaryPromptView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm: AddSummaryViewModel
    
    init(item: SummaryItem) {
        self._vm = StateObject(wrappedValue: AddSummaryViewModel(item: item, moc: DataContainer.shared.context))
    }
    
    @Environment(\.dismiss) var dismiss
    @FetchRequest<PromptEntity>(sortDescriptors: [SortDescriptor(\.createdAt, order: .forward)]) var prompts
    
    var body: some View {
        NavigationStack(path: $vm.navPath) {
            ZStack {
                ScrollView(.vertical) {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        if prompts.count == 0 {
                            addPromptButton()
                        } else {
                            promptsList()
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $vm.showAddPrompt) {
                if vm.selectedPrompt == nil {
                    vm.selectedPrompt = prompts.first
                }
            } content: {
                AddUpdatePromptView()
            }
            .toolbar {
                toolbarItems()
            }
            .task {
                if prompts.count == 1 {
                    vm.selectedPrompt = prompts.first
                }
                vm.fetchEntries()
            }
            .alert(L(.error), isPresented: $vm.showFatalError) {
                Button(L(.ok)) {
                    dismiss()
                }
            } message: {
                Text(vm.fatalErrorMessage)
            }
            .navigationDestination(for: AddSummaryNavPath.self) { s in
                if s == .preview {
                    AddSummaryPreviewView()
                        .environmentObject(vm)
                } else if s == .summarize {
                    AddSummarySummarizeView()
                        .environmentObject(vm)
                }
            }
            .onChange(of: vm.saved) { newValue in
                if newValue {
                    appState.activeTab = 1
                    dismiss()
                }
            }
        }
    }
    
    @ViewBuilder
    private func addPromptButton() -> some View {
        Text(L(.sum_no_prompts))
            .font(.title2)
            .fontWeight(.bold)
            .padding(5)
        FeedbackButton {
            vm.showAddPrompt = true
        } label: {
            Text(L(.sum_add_prompt))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 18)
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: .infinity))
        }
        .padding(5)
    }
    
    @ViewBuilder
    private func promptsList() -> some View {
        Text(L(.sum_choose_prompt))
            .font(.headline)
            .padding(5)
        ForEach(prompts) { p in
            Button {
                vm.selectedPrompt = p
            } label: {
                SummaryPromptEntryView(prompt: p, selected: vm.selectedPrompt == p)
            }
            .buttonStyle(NoEffectButtonStyle())
        }
    }
    
    @ToolbarContentBuilder
    private func toolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .cancel) {
                dismiss()
            } label: {
                Text(L(.cancel))
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button {
                vm.navPath.append(.preview)
            } label: {
                Text(L(.next))
            }
            .disabled(vm.selectedPrompt == nil)
        }
    }
}

struct AddSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        AddSummaryPromptView(item: SummaryItem.day(20231010))
    }
}
