//
//  ChildWidget.swift
//  ChildWidget
//
//  Created by 김도현 on 5/21/24.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), batteryPercentage: 90, hourOffset: 0)
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration, batteryPercentage: 80, hourOffset: 0)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        let totalTime = 13
        let currentDate = Date()
        
        for hourOffset in 0..<(totalTime + 1) {
            let percentageDropPerHour = 100.0 / Double(totalTime)
            let currentPercentage = max(100.0 - (percentageDropPerHour * Double(hourOffset % (totalTime + 1))), 0)
            let entryDate = Calendar.current.date(byAdding: .second, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, batteryPercentage: currentPercentage, hourOffset: hourOffset % (totalTime + 1))
            entries.append(entry)
        }
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let batteryPercentage: Double
    let hourOffset: Int
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
                            Text("사진 보낸지 \(entry.hourOffset)시간 됐어요")
                                .font(.body.weight(.bold))
                                .foregroundStyle(.txtFDF8F8)
                            Spacer()
                        }
                    }
                }
                Color.clear.batteryShadow(color: .battery100)
                    .frame(width: 59, height: 100)
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
    SimpleEntry(date: .now, configuration: .smiley, batteryPercentage: 90, hourOffset: 0)
}


