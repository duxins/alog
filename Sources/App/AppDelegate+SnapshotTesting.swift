//
//  AppDelegate+SnapshotTesting.swift
//  ALog
//
//  Created by Xin Du on 2023/07/23.
//

import Foundation

#if DEBUG
extension AppDelegate {
    func setupSnapshotTestEnvironment() {
        let moc = DataContainer.shared.context
        let config = Config.shared
        
        // MARK: - RESET SETTINGS
        config.sumEnabled = true
        config.transEnabled = true
        config.sumProvider = .openai
        
        // MARK: - RESET MEMOS
        let request = MemoEntity.fetchRequest()
        let results = try! moc.fetch(request)
        for result in results {
            moc.delete(result)
        }
        
        let items = [
            ["06:03", "Woke up, kind of a bummer."],
            ["07:08", "Had a big bowl of cereal, too many marshmallows maybe."],
            ["07:22", "Morning jog for 2 miles. My lungs, they're screaming!"],
            ["08:00", "Rushed shower. Thought I saw a spider. It was just shampoo."],
            ["08:32", "Hopped on the school bus. Sally's hairstyle, no comments."],
            ["12:21", "Lunch. Pizza for the third time this week. No regrets."],
            ["15:58", "Soccer practice. Sweating buckets, feeling awesome."],
            ["19:10", "Dinner. Mom's meatloaf, always a hit."],
            ["22:23", "Lights out. Big day tomorrow, looking forward to it."]
        ]
        
        for item in items {
            let m = MemoEntity(context: moc)
            m.id = UUID().uuidString
            m.content = item[1]
            m.day = Int32(DateHelper.identifier(from: Date()))
            m.timezone = "Asia/Tokyo"
            let time = item[0].split(separator: ":").map { Int($0)! }
            m.createdAt = DateHelper.timeToDate(h: time[0], m: time[1])
        }
        
        try! moc.save()
    }
}
#endif
