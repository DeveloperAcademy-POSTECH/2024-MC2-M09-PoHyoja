//
//  ParentWidget.swift
//  ParentWidget
//
//  Created by 김도현 on 5/19/24.
//

import SwiftUI
import WidgetKit


// MARK: - 부모 위젯

struct ParentProvider: TimelineProvider {
    func placeholder(in context: Context) -> ParentSimpleEntry {
        ParentSimpleEntry(date: Date(), image: UIImage())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ParentSimpleEntry) -> ()) {
        let entry = ParentSimpleEntry(date: Date(), image: UIImage(named: "ParentWidgetPreview") ?? UIImage())
        completion(entry)
    }

    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ParentSimpleEntry>) -> ()) {
        var entries: [ParentSimpleEntry] = []
        var timeline = Timeline(entries: entries, policy: .atEnd)
        
        guard let urlString = UserDefaults.shared.string(forKey: "urlString"),
              let url = URL(string: urlString)
        else {
            let entry = ParentSimpleEntry(date: Date(), image: UIImage(named: "ParentWidgetPreview") ?? UIImage())
            entries.append(entry)
            timeline = Timeline(entries: entries, policy: .atEnd)
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



struct ParentSimpleEntry: TimelineEntry {
    let date: Date
    let image: UIImage
}



struct ParentWidgetView : View {
    var entry: ParentProvider.Entry
    
    var body: some View {
        RoundedRectangle(cornerRadius: 21)
            .fill(Color.clear)
            .overlay(
                Image(uiImage: entry.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(21)
                    .clipped()
            )
            .overlay(
                RoundedRectangle(cornerRadius: 21)
                    .stroke(Color.bgSecondaryElevated, lineWidth: 20)
            )
            .containerBackground(Color.clear, for: .widget)
    }
}







struct ParentWidget: Widget {
    let kind: String = "ParentWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ParentProvider()) { entry in
            ParentWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
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
        ChildSimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), batteryPercentage: 90, hourOffset: 0)
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> ChildSimpleEntry {
        ChildSimpleEntry(date: Date(), configuration: configuration, batteryPercentage: 100, hourOffset: 0)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<ChildSimpleEntry> {
        var entries: [ChildSimpleEntry] = []
        
        let targetTime = ChildWidgetOption.targetTime // 목표로 설정한 시간
        let photoSentDate = ChildWidgetOption.photoSentDate // 사진을 보낸 시간
        
        // 근사값이라 targetTime에 어떤 값이 오더라도 배터리가 0이하가 될 수 있게 +1을 해줌
        for hourOffset in 0..<(targetTime + 1) {
            let percentageDropPerTime = 100.0 / Double(targetTime) // 배터리 줄어드는 % 계산
            let currentPercentage = max(100.0 - (percentageDropPerTime * Double(hourOffset % (targetTime + 1))), 0) // 현재 남은 배터리
            let elapsedTime = Calendar.current.date(byAdding: ChildWidgetOption.timeUnit, value: hourOffset, to: photoSentDate)! // 사진을 보낸 시간으로부터 경과된 시간
            let entry = ChildSimpleEntry(date: elapsedTime, configuration: configuration, batteryPercentage: currentPercentage, hourOffset: hourOffset % (targetTime + 1))
            entries.append(entry)
        }
        return Timeline(entries: entries, policy: .atEnd)
    }
}



struct ChildSimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let batteryPercentage: Double // 근사값이라 정확도 최대한 높이려고 Double 사용
    let hourOffset: Int // hourOffset 값을 사진 보낸지 얼마나 됐는지로도 사용
}



struct ChildWidgetEntryView : View {
    var entry: ChildProvider.Entry
    
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
                                .foregroundStyle(Color.txtPrimaryDark)
                            
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
                                .foregroundStyle(.txtAAA8A9)
                            
                            Spacer()
                        }
                    }
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            Color.bgGray3.shadow(
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
            .background(Color.bgSecondaryElevated)
        } else {
            ZStack {
                Color.bgSecondaryElevated.ignoresSafeArea()
                
                VStack(alignment: .leading){
                    HStack(alignment: .center) {
                        Text("아들아")
                    }
                    .padding(.bottom, 1)
                    Text("잘 지내니? 보고 싶다.")
                }
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.txtPrimaryDark)
            }
        }
    }
}




struct ChildWidget: Widget {
    let kind: String = "ChildWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: ChildProvider()) { entry in
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
    ChildSimpleEntry(date: .now, configuration: .smiley, batteryPercentage: 100, hourOffset: 0)
}


