//
//  AddSummaryMemoSelectionView.swift
//  ALog
//
//  Created by Xin Du on 2023/08/16.
//

import SwiftUI

struct AddSummaryMemoSelectionView: View {
    @EnvironmentObject var vm: AddSummaryViewModel
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 20) {
                    Text(L(.sum_select_memos_title))
                        .font(.headline)
                        .padding(.vertical, 5)
                    
                    ForEach(vm.validMemos) { memo in
                        selectionEntry(memo)
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    vm.navPath.append(.preview)
                } label: {
                    Text(L(.next))
                }
                .disabled(vm.selectedMemos.isEmpty)
            }
        }
    }
    
    @ViewBuilder
    private func selectionEntry(_ memo: MemoEntity) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(memo.viewTime)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Text(memo.viewContent)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if isSelected(memo) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "circle.dotted")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    isSelected(memo) ? Color(uiColor: .tertiarySystemFill) : Color(uiColor: .quaternarySystemFill)
                )
                .opacity(0.6)
        }
        .opacity(isSelected(memo) ? 1 : 0.5)
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            if isSelected(memo) {
                vm.excludedMemos.insert(memo)
            } else {
                vm.excludedMemos.remove(memo)
            }
        }
    }
    
    private func isSelected(_ memo: MemoEntity) -> Bool {
        !vm.excludedMemos.contains(memo)
    }
}


#if DEBUG
struct AddSummaryMemoSelectionView_Previews: PreviewProvider {
    static var vm = AddSummaryViewModel(item: SummaryItem.day(20230816), moc: DataContainer.preview.context)
    static var previews: some View {
        AddSummaryMemoSelectionView()
            .environmentObject(vm)
            .preferredColorScheme(.dark)
            .task {
                vm.fetchEntries()
            }
    }
}
#endif
