//
//  ParentWidget.swift
//  ParentWidget
//
//  Created by 김도현 on 5/19/24.
//

import SwiftUI
import WidgetKit


struct ParentSimpleEntry: TimelineEntry {
    let date: Date
    let image: UIImage
}

struct ParentWidgetView : View {
    var entry: ParentProvider.Entry

    var body: some View {
        Image(uiImage: entry.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .containerBackground(Color.clear, for: .widget)
    }
}

class ParentProvider: TimelineProvider {
    func placeholder(in context: Context) -> ParentSimpleEntry {
        ParentSimpleEntry(date: Date(), image: UIImage())
    }

    func getSnapshot(in context: Context, completion: @escaping (ParentSimpleEntry) -> ()) {
        let entry = ParentSimpleEntry(date: Date(), image: UIImage())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ParentSimpleEntry>) -> ()) {
        var entries: [ParentSimpleEntry] = []
        var timeline = Timeline(entries: entries, policy: .atEnd)
        
        guard let urlString = UserDefaults.shared.string(forKey: "urlString"),
              let url = URL(string: urlString)
        else {
            completion(timeline)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data, let image = UIImage(data: data) {
                let entry = ParentSimpleEntry(date: Date(), image: image)
                entries.append(entry)
                
                timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
        }
        task.resume()
    }
}


struct ParentWidget: Widget {
    let kind: String = "ParentWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ParentProvider()) { entry in
            ParentWidgetView(entry: entry)
        }
        .configurationDisplayName("PicCharge")
        .description("필요하면 나중에 설명 추가하기")
        .supportedFamilies([.systemLarge])
        .contentMarginsDisabled()
    }
}


#Preview(as: .systemLarge) {
    ParentWidget()
} timeline: {
    ParentSimpleEntry(date: .now, image: UIImage())
}

#Preview(as: .systemMedium) {
    ParentWidget()
} timeline: {
    ParentSimpleEntry(date: .now, image: UIImage())

}





