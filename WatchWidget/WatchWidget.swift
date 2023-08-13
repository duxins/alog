//
//  WatchWidget.swift
//  ALogWatchWidget
//
//  Created by Xin Du on 2023/08/07.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: Date.distantFuture)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct WatchWidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            #if os(watchOS)
            watch()
            #else
            ios()
            #endif
        }
        .widgetAccentable()
        #if os(iOS)
        .widgetURL(URL(string: "alog://record")!)
        #endif
    }
    
    @ViewBuilder
    private func watch() -> some View {
        if family == .accessoryCircular {
            Image("logo-circular")
        } else {
            Image("logo-corner")
        }
    }
    
    @ViewBuilder
    private func ios() -> some View {
        Image("logo-circular-ios")
    }
}

@main
struct WatchWidget: Widget {
    let kind: String = "main"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WatchWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ALog")
        .description("")
        #if os(watchOS)
        .supportedFamilies([.accessoryCircular, .accessoryCorner])
        #else
        .supportedFamilies([.accessoryCircular])
        #endif
    }
}

struct WatchWidget_Previews: PreviewProvider {
    static var previews: some View {
        WatchWidgetEntryView(entry: SimpleEntry(date: Date()))
        #if os(watchOS)
            .previewContext(WidgetPreviewContext(family: .accessoryCorner))
        #else
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        #endif
    }
}
