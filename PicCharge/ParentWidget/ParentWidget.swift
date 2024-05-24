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

// MARK: - 자식 위젯

struct ChildProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> ChildSimpleEntry {
        ChildSimpleEntry(date: Date(), configuration: ChildConfigurationAppIntent())
    }

    func snapshot(for configuration: ChildConfigurationAppIntent, in context: Context) async -> ChildSimpleEntry {
        ChildSimpleEntry(date: Date(), configuration: configuration)
    }

    func timeline(for configuration: ChildConfigurationAppIntent, in context: Context) async -> Timeline<ChildSimpleEntry> {
        var entries: [ChildSimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = ChildSimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct ChildSimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ChildConfigurationAppIntent
}

struct ChildWidgetEntryView : View {
    var entry: ChildProvider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Favorite Emoji:")
            Text(entry.configuration.favoriteEmoji)
        }
    }
}

struct ChildWidget: Widget {
    let kind: String = "ChildWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ChildConfigurationAppIntent.self, provider: ChildProvider()) { entry in
            ChildWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("PicCharge")
        .description("필요하면 나중에 설명 추가하기")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}

extension ChildConfigurationAppIntent {
    fileprivate static var smiley: ChildConfigurationAppIntent {
        let intent = ChildConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }

    fileprivate static var starEyes: ChildConfigurationAppIntent {
        let intent = ChildConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemMedium) {
    ChildWidget()
} timeline: {
    ChildSimpleEntry(date: .now, configuration: .smiley)
    ChildSimpleEntry(date: .now, configuration: .starEyes)
}





