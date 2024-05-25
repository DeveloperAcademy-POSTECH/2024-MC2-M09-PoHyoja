//
//  ParentWidget.swift
//  ParentWidget
//
//  Created by 김도현 on 5/19/24.
//

import SwiftUI
import WidgetKit


// MARK: - 부모 위젯


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


struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), batteryPercentage: 90, hourOffset: 0)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
            SimpleEntry(date: Date(), configuration: configuration, batteryPercentage: 100, hourOffset: 0)
        }

        func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
            var entries: [SimpleEntry] = []

            let totalTime = ChildWidgetOption.totalTime
            let photoSentDate = ChildWidgetOption.photoSentDate

            // 근사값이라 totalTime에 어떤 값이 오더라도 0이 될 수 있게 +1을 해줌
            for hourOffset in 0..<(totalTime + 1) {
                let percentageDropPerHour = 100.0 / Double(totalTime) // 배터리 줄어드는 % 계산
                let currentPercentage = max(100.0 - (percentageDropPerHour * Double(hourOffset % (totalTime + 1))), 0)
                let entryDate = ChildWidgetOption.byAdding(value: hourOffset, to: photoSentDate)
                let entry = SimpleEntry(date: entryDate, configuration: configuration, batteryPercentage: currentPercentage, hourOffset: hourOffset % (totalTime + 1))
                entries.append(entry)
            }
            return Timeline(entries: entries, policy: .atEnd)
        }
    }
    struct SimpleEntry: TimelineEntry {
        let date: Date
        let configuration: ConfigurationAppIntent
        let batteryPercentage: Double // 근사값이라 정확도 최대한 높이려고 Double 사용
        let hourOffset: Int // hourOffset 값을 사진 보낸지 얼마나 됐는지로도 사용
    }



    struct ChildWidgetEntryView : View {
        var entry: Provider.Entry

        var body: some View {
            if entry.batteryPercentage > 0 {
                HStack {
                    VStack {
                        HStack {
                            Icon.heartBolt
                            Text("픽-챠! 배터리")

                            Spacer()
                        }
                        .font(.title3.weight(.bold))
                        .foregroundColor(.green)
                        
                        Spacer()
                        
                        VStack {
                            HStack {
                                Text("\(entry.batteryPercentage, specifier: "%.0f")%")
                                    .font(.system(size: 36, weight: .bold))
                                Text("남았어요")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.txtVibrantSecondary)
                                    .opacity(0.8)
                                    .offset(y: 4)
                                
                                Spacer()
                            }
                            HStack {
                                Text("사진 보낸 지 \(entry.hourOffset)시간 됐어요")
                                    .font(.body.weight(.bold))
                                    .foregroundStyle(.txtFDF8F8)

                                Spacer()
                            }
                        }
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                Color.gray3.shadow(
                                    .inner(
                                        color: Color.white.opacity(0.25),
                                        radius: 7.5,
                                        x: 4,
                                        y: 4
                                    )
                                )
                            )
                            .stroke(.gray, lineWidth: 1)
                            .frame(width: 67, height: 120, alignment: .bottom)

                        VStack {

                            Spacer()

                            Color.clear.batteryShadow(color: Color.wgBattery(percent: entry.batteryPercentage * 0.9))
                                .frame(width: 59, height: (entry.batteryPercentage * 1.15 * 0.8) + 20, alignment: .bottom)
                        }
                        .padding(.vertical, 4)
                        .frame(width: 67, height: 120, alignment: .bottom)
                    }
                }
                .padding()
            } else {
                VStack(alignment: .leading){
                    HStack(alignment: .center) {
                        Text("아들아")
                    }
                    .padding(.bottom, 1)
                    Text("잘 지내니? 보고 싶다.")
                }
                .font(.system(size: 32, weight: .bold))
            }
        }
    }
    struct ChildWidget: Widget {
        let kind: String = "ChildWidget"
        
        var body: some WidgetConfiguration {
            AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
                ChildWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            }
            .configurationDisplayName("PicCharge")
            .description("필요하면 나중에 설명 추가하기")
            .supportedFamilies([.systemMedium])
            .contentMarginsDisabled()
        }
    }
    extension ConfigurationAppIntent {
        fileprivate static var smiley: ConfigurationAppIntent {
            let intent = ConfigurationAppIntent()
            intent.favoriteEmoji = "😀"
            return intent
        }
        
    }
    #Preview(as: .systemMedium) {
        ChildWidget()
    } timeline: {
        SimpleEntry(date: .now, configuration: .smiley, batteryPercentage: 100, hourOffset: 0)
    }



