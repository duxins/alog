//
//  SummaryDetailView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/22.
//

import SwiftUI
import XLog

struct SummaryDetailView: View {
    @ObservedObject var summary: SummaryEntity
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Text(summary.viewContent)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
            .toolbar {
                ToolbarItem {
                    Menu {
                        ShareLink(item: summary.shareContent) {
                            Image(systemName: "square.and.arrow.up")
                            Text(L(.share))
                        }
                        
                        Button {
                            appState.activeSheet = .editSummary(summary)
                        } label: {
                            Image(systemName: "square.and.pencil")
                            Text(L(.edit))
                        }
                        
                        Menu(L(.export)) {
                            Button {
                                ShareHelper.share(items: [markdown()])
                            } label: {
                                Text("Markdown")
                            }
                            
                            Button {
                                ShareHelper.share(items: [pdf()])
                            } label: {
                                Text("PDF")
                            }
                        }
                        
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Image(systemName: "trash")
                            Text(L(.delete))
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(title: Text(L(.are_you_sure)), primaryButton: .destructive(Text(L(.delete))) {
                    moc.delete(summary)
                    try? moc.save()
                    dismiss()
                }, secondaryButton: .cancel())
            }
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle(summary.viewTitle)
    }
    
    private func markdown() -> URL {
        let url = fileName(ext: "md")
        try? summary.shareContent.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
    
    private func pdf() -> URL {
        let url = fileName(ext: "pdf")
        let renderer = ImageRenderer(content:
            VStack(spacing: 30) {
                Group {
                    Text(summary.viewTitle)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(summary.viewContent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(30)
            .frame(width: 600)
            .frame(minHeight: 860)
        )
        
        renderer.render { size, context in
            var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
                return
            }
            pdf.beginPDFPage(nil)
            context(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
        }
        return url
    }
    
    private func fileName(ext: String = "md") -> URL {
        let illegalCharacters = CharacterSet(charactersIn: "/*\"<>&$`~:;%?\\")
        let fileName = summary.viewTitle.components(separatedBy: illegalCharacters).joined()
        let url = URL(filePath: NSTemporaryDirectory()).appending(path: "summary-\(fileName).\(ext)")
        XLog.debug("Export summary to \(url)", source: "Export")
        return url
    }
}

#if DEBUG
struct SummaryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryDetailView(summary: SummaryEntity.preview())
            .preferredColorScheme(.dark)
            .environment(\.managedObjectContext, DataContainer.preview.context)
    }
}
#endif
