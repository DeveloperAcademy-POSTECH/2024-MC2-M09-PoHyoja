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
        ParentEntry.default
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> ParentEntry {
        let entry = ParentEntry.default
        
        do {
            guard let user = await localRepository.fetchUser() else {
                return entry
            }
            
            let photo = await remoteRepository.fetchLatestPhoto(user.name)
            
            if let urlString = photo?.urlString {
                let imgData = try await remoteRepository.downloadPhotoData(of: urlString)
                
                switch context.family {
                case .systemLarge:
                    if let image = imgData.downsampling(to: .widget_main) {
                        return ParentEntry(date: .now, image: image)
                    }
                    
                case .systemSmall:
                    if let image = imgData.downsampling(to: .widget_thumb) {
                        return ParentEntry(date: .now, image: image)
                    }
                    
                default: break
                }
            }
        } catch {
            return entry
        }
        
        return entry
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<ParentEntry> {
        var entry = ParentEntry.default
        
        do {
            guard let user = await localRepository.fetchUser() else {
                return Timeline(entries: [entry], policy: .atEnd)
            }
            
            let photo = await remoteRepository.fetchLatestPhoto(user.name)
            
            if let urlString = photo?.urlString {
                let imgData = try await remoteRepository.downloadPhotoData(of: urlString)
                
                switch context.family {
                case .systemLarge:
                    if let image = imgData.downsampling(to: .widget_main) {
                        entry = ParentEntry(date: .now, image: image)
                    }
                    
                case .systemSmall:
                    if let image = imgData.downsampling(to: .widget_thumb) {
                        entry = ParentEntry(date: .now, image: image)
                    }  
                    
                default: break
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
    static let `default` = ParentEntry(date: Date(), image: UIImage(named: "ParentWidgetPreview") ?? UIImage())
    
    let date: Date
    let image: UIImage
}

struct ParentWidgetView : View {
    var entry: ParentProvider.Entry
    
    var body: some View {
        GeometryReader { gr in
            Image(uiImage: entry.image)
                .resizable()
                .frame(width: gr.size.width, height: gr.size.height)
                .scaledToFit()
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
