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
        .default
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> ParentEntry {
        guard let imgData = await fetchImgData() else { return .default }
        
        let entry = buildEntry(imgData: imgData, in: context.family)
        
        return entry
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<ParentEntry> {
        guard let imgData = await fetchImgData() else {
            return Timeline(entries: [.default], policy: .atEnd)
        }
        
        let entry = buildEntry(imgData: imgData, in: context.family)
        
        return Timeline(entries: [entry], policy: .atEnd)
    }
    
    private func buildEntry(imgData: Data, in widgetFamily: WidgetFamily) -> ParentEntry {
        let imageSize: CGSize
        
        switch widgetFamily {
        case .systemLarge: imageSize = .widget_main
        case .systemSmall: imageSize = .widget_thumb
        default:
            return .default
        }
        
        if let image = imgData.downsampling(to: imageSize) {
            return ParentEntry(date: .now, image: image)
        }
        
        return .default
    }

    private func fetchImgData() async -> Data? {
        guard let user = await localRepository.fetchUser() else { return nil }
        
        let photo = await remoteRepository.fetchLatestPhoto(user.name)

        guard let urlString = photo?.urlString else { return nil }
        
        return try? await remoteRepository.downloadPhotoData(of: urlString)
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
