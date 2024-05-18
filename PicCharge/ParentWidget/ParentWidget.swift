//
//  ParentWidget.swift
//  ParentWidget
//
//  Created by 김도현 on 5/19/24.
//

import SwiftUI
import WidgetKit

struct SimpleEntry: TimelineEntry {
    let date: Date
    let image: UIImage
}

struct ImageProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), image: UIImage())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), image: UIImage())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []
        let url = URL(string: "https://img.movist.com/?img=/x00/00/00/20_p1.jpg")!

        let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data, let image = UIImage(data: data) {
                let entry = SimpleEntry(date: Date(), image: image)
                entries.append(entry)
                
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
        }
        task.resume()
    }
}

struct ParentWidget: Widget {
    let kind: String = "ParentWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ImageProvider()) { entry in
            Image(uiImage: entry.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .configurationDisplayName("PicCharge")
        .description("필요하면 나중에 설명 추가하기")
        .supportedFamilies([.systemLarge])
    }
}

