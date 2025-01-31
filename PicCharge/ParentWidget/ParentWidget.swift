//
//  ParentWidget.swift
//  ParentWidget
//
//  Created by 김도현 on 5/19/24.
//

import SwiftUI
import WidgetKit
import FirebaseCore
import SwiftData

// MARK: - 부모 위젯
struct ParentProvider: AppIntentTimelineProvider {
    let localRepository: LocalRepository
    let remoteRepository: RemoteRepository
    
    func placeholder(in context: Context) -> ParentEntry {
        ParentEntry(date: Date(), image: UIImage(named: "ParentWidgetPreview") ?? UIImage())
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> ParentEntry {
        let entry = ParentEntry(date: Date(), image: UIImage(named: "ParentWidgetPreview") ?? UIImage())
        
        do {
            guard let user = await getLocalUser() else {
                return entry
            }
            
            let photo = await remoteRepository.fetchLatestPhoto(user.name)
            
            if let urlString = photo?.urlString {
                let imgData = try await remoteRepository.downloadPhotoData(of: urlString)
                
                if let image = UIImage(data: imgData) {
                    return ParentEntry(date: Date(), image: image)
                }
            }
        } catch {
            return entry
        }
        
        return entry
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<ParentEntry> {
        var entry: ParentEntry = ParentEntry(date: Date(), image: UIImage(named: "ParentWidgetPreview") ?? UIImage())
        
        do {
            guard let user = await getLocalUser() else {
                return Timeline(entries: [entry], policy: .atEnd)
            }
            
            let photo = await remoteRepository.fetchLatestPhoto(user.name)
            
            if let urlString = photo?.urlString {
                let imgData = try await remoteRepository.downloadPhotoData(of: urlString)
                
                if let image = UIImage(data: imgData) {
                    entry = ParentEntry(date: Date(), image: image)
                }
            }
            
        } catch {
            print("위젯 에러!")
            return Timeline(entries: [entry], policy: .atEnd)
        }
        
        return Timeline(entries: [entry], policy: .atEnd)
    }
    
    func getLocalUser() async -> User? {
        await localRepository.fetchUser()
    }
}

struct ParentEntry: TimelineEntry {
    let date: Date
    let image: UIImage
}

struct ParentWidgetView : View {
    var entry: ParentProvider.Entry
    
    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 21)
                .fill(Color.clear)
                .overlay(
                    Image(uiImage: entry.image.resized(toWidth: geometry.size.width, isOpaque: true)!)
                        .resizable()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .cornerRadius(21)
                        .clipped()
                )
                .containerBackground(Color.clear, for: .widget)
        }
    }
}

struct ParentWidget: Widget {
    let kind: String = "ParentWidget"
    let localRepository: LocalRepository
    let remoteRepository: RemoteRepository
    
    init() {
        let filePath = Bundle.main.path(forResource: "../../GoogleService-Info", ofType: "plist")!
        let options = FirebaseOptions(contentsOfFile: filePath)
        FirebaseApp.configure(options: options!)
        
        localRepository = DefaultLocalRepository()
        remoteRepository = DefaultRemoteRepository()
    }
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: ParentProvider(localRepository: localRepository,
                                     remoteRepository: remoteRepository)
        ) {
            ParentWidgetView(entry: $0)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("자식 앨범")
        .description("자식이 올린 사진을 보아요.")
        .supportedFamilies([.systemSmall, .systemLarge])
        .contentMarginsDisabled()
    }
}

#Preview(as: .systemSmall) {
    ParentWidget()
} timeline: {
    ParentEntry(date: .now, image: UIImage())
}
