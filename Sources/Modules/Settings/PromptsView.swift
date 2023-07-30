//
//  PromptsView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/15.
//

import SwiftUI

struct PromptsView: View {
    @State private var showAddPrompt = false
    @State private var showPremium = false
    @State private var promptToEdit: PromptEntity?
    @EnvironmentObject var appState: AppState
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest<PromptEntity>(sortDescriptors: [SortDescriptor(\.createdAt, order: .forward)]) var prompts
    
    let limit = Constants.Limit.prompts
    
    var body: some View {
        VStack {
            Form {
                ForEach(prompts) { p in
                    Button {
                        promptToEdit = p
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(p.viewTitle)
                            if p.viewDesc != "" {
                                Text(p.viewDesc)
                                    .foregroundColor(Color(uiColor: .tertiaryLabel))
                                    .font(.footnote)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deletePrompt)
                addPromptSection()
            }
            .sheet(isPresented: $showPremium) {
                PremiumView()
            }
        }
        .navigationTitle(appState.isPremium ? L(.settings_sum_prompts) : "\(L(.settings_sum_prompts)) (\(prompts.count)/\(limit))")
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(item: $promptToEdit) { p in
            AddUpdatePromptView(prompt: p)
                .interactiveDismissDisabled()
        }
    }
    
    private func deletePrompt(at offsets: IndexSet) {
        for index in offsets {
            moc.delete(prompts[index])
        }
        try? moc.save()
    }
    
    @ViewBuilder
    private func addPromptSection() -> some View {
        Section {
            if appState.isPremium || prompts.count < limit {
                Button {
                    showAddPrompt = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text(L(.settings_sum_prompts_add))
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                Button {
                    showPremium = true
                } label: {
                    HStack {
                        Image(systemName: "lock.fill")
                        Text(L(.settings_sum_prompts_add))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .sheet(isPresented: $showAddPrompt) {
            AddUpdatePromptView()
                .interactiveDismissDisabled()
        }
    }
}

struct PromptsView_Previews: PreviewProvider {
    static var previews: some View {
        PromptsView()
            .preferredColorScheme(.dark)
    }
}
