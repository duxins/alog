//
//  AddSummaryPreviewView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/22.
//

import SwiftUI

struct AddSummaryPreviewView: View {
    @EnvironmentObject var vm: AddSummaryViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Form {
                Section {
                    MyTextView(text: $vm.summaryMessage)
                } header: {
                    HStack {
                        Spacer()
                        Text("\(L(.characters)): \(vm.summaryMessageCharCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .headerProminence(.increased)
            }
        }
        .navigationTitle(L(.preview))
        .task {
            vm.generateMessage()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    hideKeyboard()
                    vm.navPath.append(.summarize)
                } label: {
                    Text(L(.summarize))
                }
                .disabled(vm.summaryMessage.isEmpty)
            }
        }
    }
}

#if DEBUG
struct AddSummaryPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        AddSummaryPreviewView()
            .environmentObject(AddSummaryViewModel(item: SummaryItem.day(20230722), moc: DataContainer.preview.context))
    }
}
#endif
