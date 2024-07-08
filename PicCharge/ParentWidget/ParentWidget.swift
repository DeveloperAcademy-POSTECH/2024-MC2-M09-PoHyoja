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
    enum SwiftDataError: Error {
        case notExist
    }
    
    let container: ModelContainer
    
    func placeholder(in context: Context) -> ParentEntry {
        ParentEntry(date: Date(), image: UIImage(named: "ParentWidgetPreview") ?? UIImage())
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> ParentEntry {
        let entry = ParentEntry(date: Date(), image: UIImage(named: "ParentWidgetPreview") ?? UIImage())
        
        do {
            guard let user = await getUserForSwiftData() else {
                return entry
            }
            
            var photos: [Photo] = []
            photos = try await FirestoreService.shared.fetchPhotos(userName: user.name)
            photos.sort { $0.uploadDate < $1.uploadDate }
            
            if let lastPhoto = photos.last {
                let imgData = try await FirestoreService.shared.fetchPhotoData(urlString: lastPhoto.urlString)
                
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
            guard let user = await getUserForSwiftData() else {
                return Timeline(entries: [entry], policy: .atEnd)
            }
            
            var photos: [Photo] = []
            photos = try await FirestoreService.shared.fetchPhotos(userName: user.name)
            photos.sort { $0.uploadDate < $1.uploadDate }
            
            if let lastPhoto = photos.last {
                let imgData = try await FirestoreService.shared.fetchPhotoData(urlString: lastPhoto.urlString)
                
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
    
    @MainActor func getUserForSwiftData() -> UserForSwiftData? {
        let descriptor = FetchDescriptor<UserForSwiftData>()
        
        let user = (try? container.mainContext.fetch(descriptor))?.first ?? nil
        
        return user
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
    var container: ModelContainer
    
    init() {
        FirebaseApp.configure()
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
            provider: ParentProvider(container: container)
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
