//
//  ExportView.swift
//  ALog
//
//  Created by Xin Du on 2023/08/19.
//

import SwiftUI
import CoreData

struct ExportView: View {
    @StateObject private var vm: ExportViewModel
    @Environment(\.dismiss) var dismiss
    
    init(moc: NSManagedObjectContext = DataContainer.shared.context) {
        self._vm = StateObject(wrappedValue: ExportViewModel(moc: moc))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(selection: $vm.category) {
                        ForEach(ExportCategory.enabledCases, id: \.self) {
                            Text($0.displayName)
                                .tag($0)
                        }
                    } label: {
                        Text(L(.export_category))
                    }
                
                    Picker(selection: $vm.format) {
                        ForEach(ExportFormat.allCases, id: \.self) {
                            Text($0.displayName)
                                .tag($0)
                        }
                    } label: {
                        Text(L(.export_format))
                    }
                }
                
                Section {
                    Button {
                        vm.export()
                    } label: {
                        HStack {
                            Text(L(.export))
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(vm.showShareSheet)
                    .background(SharingViewController(isPresenting: $vm.showShareSheet) {
                        let av = UIActivityViewController(activityItems: [vm.fileToShare!], applicationActivities: nil)
                        if UIDevice.current.userInterfaceIdiom == .pad {
                           av.popoverPresentationController?.sourceView = UIView()
                        }
                        av.completionWithItemsHandler = { _, _, _, _ in
                            vm.showShareSheet = false
                        }
                        return av
                    })
                }
            }
            .navigationTitle(L(.export_data))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text(L(.cancel))
                    }
                }
            }
            .alert(L(.error), isPresented: $vm.showError) {
            } message: {
                Text(vm.lastErrorMessage)
            }
        }
    }
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView(moc: DataContainer.preview.context)
            .preferredColorScheme(.dark)
    }
}
