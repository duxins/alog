//
//  ExportViewModel.swift
//  ALog
//
//  Created by Xin Du on 2023/08/19.
//

import Foundation
import CoreData
import XLog
import CSV

enum ExportCategory: CaseIterable {
    case note
    case summary
    
    static var enabledCases: [ExportCategory] {
        if Config.shared.sumEnabled {
            return [.note, .summary]
        } else {
            return [.note]
        }
    }
    
    var displayName: String {
        switch self {
        case .note: return L(.export_category_note)
        case .summary: return L(.export_category_summary)
        }
    }
    
    var fileName: String {
        switch self {
        case .note: return "Notes"
        case .summary: return "Summaries"
        }
    }
}

enum ExportFormat: CaseIterable {
    case csv
    case markdown
    
    var displayName: String {
        switch self {
        case .csv: return "CSV"
        case .markdown: return "Markdown"
        }
    }
    
    var fileExtension: String {
        switch self {
        case .csv: return ".csv"
        case .markdown: return ".md"
        }
    }
}

class ExportViewModel: ObservableObject {
    private let moc: NSManagedObjectContext
    
    @Published var category = ExportCategory.note
    @Published var format = ExportFormat.csv
    
    @Published var fileToShare: URL? {
        didSet {
            if fileToShare != nil {
                showShareSheet = true
            }
        }
    }
    @Published var showShareSheet = false
    
    @Published var lastErrorMessage = "" {
        didSet {
            showError = true
        }
    }
    @Published var showError = false
    
    init(moc: NSManagedObjectContext) {
        self.moc = moc
    }
    
    func export() {
        do {
            if format == .csv {
                try exportAsCSV()
            } else {
                try exportAsMarkdown()
            }
        } catch {
            XLog.error(error, source: "Export")
            lastErrorMessage = ErrorHelper.desc(error)
        }
    }
    
    private func getExportFilePath() throws -> URL {
        let exportDirectory = URL.documentsDirectory.appending(path: "exports")
        let fs = FileManager.default
        if !fs.fileExists(atPath: exportDirectory.path()) {
            try fs.createDirectory(at: exportDirectory, withIntermediateDirectories: true)
        }
        let name = "\(category.fileName)-" + DateHelper.format(Date(), dateFormat: "yyyy-MM-dd-HH-mm-ss") + format.fileExtension
        let ret = exportDirectory.appending(path: name)
        return ret
    }
    
    // MARK: - CSV
    
    private func exportAsCSV() throws {
        let csvURL = try getExportFilePath()
        let rows = try genRows()
        let stream = OutputStream(toFileAtPath: csvURL.path(), append: false)!
        let csv = try CSVWriter(stream: stream)
        for row in rows {
            try csv.write(row: row)
        }
        csv.stream.close()
        fileToShare = csvURL
    }
    
    private func genRows() throws -> [[String]] {
        var rows = [[String]]()
        if category == .note {
            rows.append(["time", "content"])
            let items = try moc.fetch(notesRequest())
            for item in items {
                rows.append([item.viewCreatedAt, item.viewContent])
            }
        } else if category == .summary {
            rows.append(["time", "title", "content"])
            let items = try moc.fetch(summariesRequest())
            for item in items {
                rows.append([item.viewCreatedAt, item.viewTitle, item.viewContent])
            }
        }
        return rows
    }
    
    // MARK: - Markdown
    
    private func exportAsMarkdown() throws {
        let url = try getExportFilePath()
        let content = try genMarkdownContent()
        try content.write(to: url, atomically: true, encoding: .utf8)
        fileToShare = url
    }
    
    private func genMarkdownContent() throws -> String {
        var ret = ""
        if category == .note {
            let items = try moc.fetch(notesRequest())
            for item in items {
                ret.append("### \(item.viewCreatedAt)\n\n")
                ret.append("\(item.viewContent)\n\n\n")
            }
        } else if category == .summary {
            let items = try moc.fetch(summariesRequest())
            for item in items {
                ret.append("## \(item.viewTitle)\n\n")
                ret.append("\(item.viewContent)\n\n\n")
            }
        }
        return ret
    }
    
    // MARK: - Fetch Requests
    
    private func notesRequest() -> NSFetchRequest<MemoEntity> {
        let request = MemoEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MemoEntity.createdAt, ascending: true)]
        return request
    }
    
    private func summariesRequest() -> NSFetchRequest<SummaryEntity> {
        let request = SummaryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SummaryEntity.createdAt, ascending: true)]
        return request
    }
}
