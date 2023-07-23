//
//  TimelineHeaderView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/12.
//

import SwiftUI

struct TimelineHeaderView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var config: Config
    @Environment(\.managedObjectContext) var moc
    
    let dayId: Int
    let date: Date
    
    init(dayId: Int) {
        self.dayId = dayId
        self.date = Calendar.current.date(from: DateHelper.components(from: dayId)) ?? Date()
    }
    
    var body: some View {
        HStack {
            Group {
                Text(DateHelper.format(date, dateFormat: "dd"))
                    .font(.system(size: 32, weight: .bold, design: .serif))
                VStack(alignment: .leading, spacing: 2) {
                    Group {
                        Text(DateHelper.format(date, dateFormat: "EEE").uppercased())
                        Text(DateHelper.format(date, dateFormat: "yyyy.M"))
                    }
                    .font(.system(size: 11, weight: .bold, design: .serif))
                }
                .foregroundColor(Color(uiColor: .tertiaryLabel))
            }
            Spacer()
            
            Menu {
                
                if config.sumEnabled {
                    Button {
                        appState.activeSheet = ActiveSheet.summarize(SummaryItem.day(dayId))
                    } label: {
                        Image(systemName: "chart.bar.doc.horizontal")
                        Text("Summarize")
                    }
                }
                
                Button {
                    let markdown = Exporter.exportMemos(dayId, moc: moc)
                    ShareHelper.share(items: [markdown])
                } label: {
                    Image(systemName: "square.and.arrow.up.on.square")
                    Text("Export")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .padding(8)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 18)
        .background(Color.app_bg)
    }
}

#if DEBUG
struct TimelineHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineHeaderView(dayId: 20230101)
    }
}
#endif
