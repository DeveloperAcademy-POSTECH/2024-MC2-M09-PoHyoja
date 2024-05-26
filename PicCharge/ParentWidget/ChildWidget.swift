//
//  ChildWidget.swift
//  PicCharge
//
//  Created by 남유성 on 5/27/24.
//

import SwiftUI
import WidgetKit
import SwiftData

struct ChildProvider: AppIntentTimelineProvider {
    let container: ModelContainer
    
    func placeholder(in context: Context) -> ChildEntry {
        ChildEntry(date: Date(), configuration: ConfigurationAppIntent(), batteryPercentage: 90, hourOffset: 0)
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> ChildEntry {
        ChildEntry(date: Date(), configuration: configuration, batteryPercentage: 100, hourOffset: 0)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<ChildEntry> {
        var entries: [ChildEntry] = []
        
        let targetTime = ChildWidgetOption.targetTime // 목표로 설정한 시간
        let photoSentDate = await getLastUploadedDate() ?? Date() // 사진을 보낸 시간
        
        // 근사값이라 targetTime에 어떤 값이 오더라도 배터리가 0이하가 될 수 있게 +1을 해줌
        for hourOffset in 0..<(targetTime + 1) {
            let percentageDropPerTime = 100.0 / Double(targetTime) // 배터리 줄어드는 % 계산
            let currentPercentage = max(100.0 - (percentageDropPerTime * Double(hourOffset % (targetTime + 1))), 0) // 현재 남은 배터리
            let elapsedTime = Calendar.current.date(byAdding: ChildWidgetOption.timeUnit, value: hourOffset, to: photoSentDate)! // 사진을 보낸 시간으로부터 경과된 시간
            let entry = ChildEntry(date: elapsedTime, configuration: configuration, batteryPercentage: currentPercentage, hourOffset: hourOffset % (targetTime + 1))
            entries.append(entry)
        }
        return Timeline(entries: entries, policy: .atEnd)
    }
    
    @MainActor func getLastUploadedDate() -> Date? {
        let descriptor = FetchDescriptor<PhotoForSwiftData>(sortBy: [SortDescriptor(\.uploadDate)])
        let date = (try? container.mainContext.fetch(descriptor))?.last?.uploadDate ?? nil
        return date
    }
}

struct ChildEntry: TimelineEntry {
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
    var container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: UserForSwiftData.self, PhotoForSwiftData.self)
        } catch {
            fatalError("Failed to configure SwiftData container.")
        }
    }
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: ChildProvider(container: container)
        ) {
            ChildWidgetEntryView(entry: $0)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("자식 배터리")
        .description("배터리를 보며 사진을 보내보아요.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}

#Preview(as: .systemMedium) {
    ChildWidget()
} timeline: {
    ChildEntry(date: .now, configuration: .init(), batteryPercentage: 100, hourOffset: 0)
}
