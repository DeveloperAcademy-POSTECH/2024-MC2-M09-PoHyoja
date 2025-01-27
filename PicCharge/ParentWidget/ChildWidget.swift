//
//  ChildWidget.swift
//  PicCharge
//
//  Created by 남유성 on 5/27/24.
//

import SwiftUI
import WidgetKit
import SwiftData
import FirebaseCore

struct ChildProvider: AppIntentTimelineProvider {
    let localStorageRepository: LocalStorageService
    let remoteStorageRepository: RemoteStorageService
    
    func placeholder(in context: Context) -> ChildEntry {
        ChildEntry(date: Date(), configuration: ConfigurationAppIntent(), batteryPercentage: 90, lastUploadedDate: Date())
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> ChildEntry {
        let currentTime = Date()
        let uploadCycle = await getUploadCycle()
        let lastUploadDate = await getLatestUploadedDate()
        
        let currentPercentage = BatteryCalculator.calculateBatteryPercentage(
            lastUploadDate: lastUploadDate,
            uploadCycle: uploadCycle,
            currentTime: currentTime
        )
        
        return ChildEntry(date: currentTime, configuration: configuration, batteryPercentage: currentPercentage, lastUploadedDate: lastUploadDate)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<ChildEntry> {
        var entries: [ChildEntry] = []
        
        let uploadCycle = await getUploadCycle()
        let lastUploadDate = await getLatestUploadedDate()
        
        for timeOffset in 0..<12 {
            let elapsedTime = Calendar.current.date(byAdding: .minute, value: timeOffset * 5, to: .now)!
            
            let currentPercentage = BatteryCalculator.calculateBatteryPercentage(
                lastUploadDate: lastUploadDate,
                uploadCycle: uploadCycle,
                currentTime: elapsedTime
            )
            
            let entry = ChildEntry(
                date: elapsedTime,
                configuration: configuration,
                batteryPercentage: currentPercentage,
                lastUploadedDate: lastUploadDate
            )
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .after(.now.addingTimeInterval(300)))
    }
    
    private func getLatestUploadedDate() async -> Date {
        guard let user = await localStorageRepository.fetchUser() else { return .now }
        
        return await remoteStorageRepository.fetchLatestPhoto(user.name)?.uploadDate ?? .now
    }
    
    private func getUploadCycle() async -> Int {
        await localStorageRepository.fetchUser()?.uploadCycle ?? 3
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
        VStack {
            if entry.batteryPercentage > 0 {
                HStack {
                    VStack(spacing: -15) {
                        HStack(spacing: 5) {
                            Icon.heartBolt
                            Text("배터리")
                            
                            Spacer()
                        }
                        .font(.system(size:15, weight: .semibold))
                        .foregroundColor(.accent)
                        .padding(.bottom, -3)
                        
                        Spacer()
                        
                        VStack {
                            HStack {
                                Text("\(entry.batteryPercentage, specifier: "%.0f")%")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundStyle(Color.txtPrimaryDark)
                                
                                Text("남았어요")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.txtVibrantTertiary)
                                    .opacity(0.8)
                                    .offset(y: 4)
                                
                                Spacer()
                            }
                            
                            HStack {
                                Text("사진 보낸 지 \(entry.lastUploadedDate.timeIntervalKRString()) 됐어요")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.txtAAA8A9)
                                
                                Spacer()
                            }
                            
                            HStack {
                                Link(destination: URL(string: getPercentEcododedString("widget://deeplink?route=gallery"))!) {
                                    HStack(spacing: 5) {
                                        Image(systemName: "bolt.circle.fill")
                                        Text("충전하러가기")
                                    }
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Color.white)
                                    .frame(width: 225, height: 30)
                                    .background(entry.batteryPercentage <= 10 ? Color(red: 0.875, green: 0.157, blue: 0) : .accent)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                
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
        .background(Color.bgSecondaryElevated)
    }
    
    private func getPercentEcododedString(_ string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}

struct ChildWidget: Widget {
    let kind: String = "ChildWidget"
    let localStorageRepository: LocalStorageService
    let remoteStorageRepository: RemoteStorageService
    
    init() {
        let filePath = Bundle.main.path(forResource: "../../GoogleService-Info", ofType: "plist")!
        let options = FirebaseOptions(contentsOfFile: filePath)
        FirebaseApp.configure(options: options!)
        
        localStorageRepository = SwiftDataRepository()
        remoteStorageRepository = FireStoreRepository(fireStore: .firestore(), storage: .storage())
    }
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: ChildProvider(
                localStorageRepository: localStorageRepository,
                remoteStorageRepository: remoteStorageRepository
            )
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
