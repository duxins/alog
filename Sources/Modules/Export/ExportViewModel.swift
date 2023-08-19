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
    case notes
    case summary
    
    var displayName: String {
        switch self {
        case .notes: return L(.export_category_notes)
        case .summary: return L(.export_category_summaries)
        }
    }
}

class ExportViewModel: ObservableObject {
    private let moc: NSManagedObjectContext
    
    @Published var category = ExportCategory.notes
    @Published var fileToShare: URL? {
        didSet {
            if fileToShare != nil {
                showShareSheet = true
            }
        }
    }
    @Published var showShareSheet = false
    
    init(moc: NSManagedObjectContext) {
        self.moc = moc
    }
    
    func export() {
        do {
            try exportAsCSV()
        } catch {
            XLog.error(error, source: "Export")
        }
    }
    
    // MARK: - CSV
    
    private func exportAsCSV() throws {
        let rows = try genRows()
        let exportDirectory = URL.documentsDirectory.appending(path: "exports")
        let fs = FileManager.default
        if !fs.fileExists(atPath: exportDirectory.path()) {
            try fs.createDirectory(at: exportDirectory, withIntermediateDirectories: true)
        }
        let name = "\(category.displayName)-" + DateHelper.format(Date(), dateFormat: "yyyy-MM-dd-HH-mm-ss") + ".csv"
        let csvURL = exportDirectory.appending(path: name)
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
        if category == .notes {
            let items = try moc.fetch(notesRequest())
            for item in items {
                rows.append([item.viewCreatedAt, item.viewContent])
            }
        } else if category == .summary {
            let items = try moc.fetch(summariesRequest())
            for item in items {
                rows.append([item.viewCreatedAt, item.viewTitle, item.viewContent])
            }
        }
        return rows
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
