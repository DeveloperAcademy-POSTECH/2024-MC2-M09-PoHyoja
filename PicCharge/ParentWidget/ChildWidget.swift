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
        ChildEntry(date: Date(), configuration: ConfigurationAppIntent(), batteryPercentage: 90, lastUploadedDate: Date())
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> ChildEntry {
        let currentTime = Date()
        let uploadCycle = await getUploadCycle() ?? 3
        let lastUploadDate = await getLastUploadedDate()
        
        let currentPercentage = currentTime.calculateBatteryPercentage(
            uploadCycle: uploadCycle,
            lastUploadDate: lastUploadDate
        )
        
        return ChildEntry(
            date: currentTime,
            configuration: configuration,
            batteryPercentage: currentPercentage,
            lastUploadedDate: lastUploadDate ?? Date()
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<ChildEntry> {
        var entries: [ChildEntry] = []
        
        let uploadCycle = await getUploadCycle() ?? 3
        let lastUploadDate = await getLastUploadedDate()
        
        let totalHalfHours = uploadCycle * 24 * 2  // 30분마다 갱신
        for halfHourOffset in 0...totalHalfHours {
            let futureDate = Calendar.current.date(byAdding: .minute, value: halfHourOffset * 30, to: .now)!
            
            let currentPercentage = futureDate.calculateBatteryPercentage(
                uploadCycle: uploadCycle,
                lastUploadDate: lastUploadDate
            )
            
            let entry = ChildEntry(
                date: futureDate,
                configuration: configuration,
                batteryPercentage: currentPercentage,
                lastUploadedDate: lastUploadDate ?? Date()
            )
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
    
    @MainActor func getLastUploadedDate() -> Date? {
        var descriptor = FetchDescriptor<PhotoEntity>(sortBy: [SortDescriptor(\.uploadDate, order: .reverse)])
        descriptor.fetchLimit = 1
        let date = (try? container.mainContext.fetch(descriptor))?.first?.uploadDate ?? nil
        return date
    }
    
    @MainActor func getUploadCycle() -> Int? {
        let descriptor = FetchDescriptor<UserEntity>()
        let uploadCycle = (try? container.mainContext.fetch(descriptor))?.last?.uploadCycle ?? nil
        return uploadCycle
    }
}

struct ChildEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let batteryPercentage: Double // 근사값이라 정확도 최대한 높이려고 Double 사용
    let lastUploadedDate: Date
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
                                .foregroundStyle(.txtVibrantTertiary)
                                .opacity(0.8)
                                .offset(y: 4)
                            
                            Spacer()
                        }
                        HStack {
                            Text("사진 보낸 지 \(entry.lastUploadedDate.timeIntervalKRString()) 됐어요")
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
            container = try ModelContainer(for: UserEntity.self,
                                           PhotoEntity.self)
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
    ChildEntry(date: .now, configuration: .init(), batteryPercentage: 100, lastUploadedDate: Date())
}
