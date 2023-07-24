//
//  AddSummarySummarizeView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/22.
//

import SwiftUI

struct AddSummarySummarizeView: View {
    @EnvironmentObject var vm: AddSummaryViewModel
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                LazyVStack {
                    if vm.summaryError.count > 0 {
                        errorView
                    }
                    Text(vm.summarizedResponse)
                        .foregroundColor(vm.isSummarizing ? .secondary : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 20)
                    Spacer()
                        .frame(height: 100)
                }
                .padding(.horizontal, 16)
            }
            
            if (!(vm.isSummarizing || vm.summarizedResponse.isEmpty)) {
                VStack {
                    Spacer()
                    FeedbackButton {
                        vm.save()
                    } label: {
                        Text(L(.save))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(20)
            }
        }
        .task {
            vm.summarize()
        }
        .onDisappear {
            vm.cancelTasks()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                if vm.isSummarizing {
                    ProgressView()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Menu {
                    Button {
                    } label: {
                        Text("save")
                    }
                    
                    Button {
                        vm.summarize()
                    } label: {
                        Text("Resummarize")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
                .disabled(vm.isSummarizing || vm.summarizedResponse.isEmpty)
            }
        }
    }
    
    private var errorView: some View {
        VStack {
            Text(vm.summaryError)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 20)
            
            Button {
                vm.summarize()
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text(L(.try_again))
                }
            }
            .buttonStyle(TryAgainButtonStyle())
        }
    }
}

#if DEBUG
struct AddSummaryFinalView_Previews: PreviewProvider {
    static var previews: some View {
        AddSummarySummarizeView()
            .environmentObject(AddSummaryViewModel(item: SummaryItem.day(20230722), moc: DataContainer.preview.context))
    }
}
#endif
