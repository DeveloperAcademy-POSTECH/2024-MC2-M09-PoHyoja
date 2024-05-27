//
//  ChildAlbumView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ChildAlbumView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(\.modelContext) var modelContext
    
    @Query(sort: \PhotoForSwiftData.uploadDate, order: .reverse) var photoForSwiftDatas: [PhotoForSwiftData]
    @Bindable var user: UserForSwiftData
    var didRefresh: () async -> Void
    
    //geometryReader로 3등분
    let columnLayout = [
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3)
    ]
    
    var body: some View {
        Group {
            if let first = photoForSwiftDatas.first {
                ScrollView {
                    Divider()
                        .padding(.bottom, 10)
                    
                    VStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("최근 업로드 사진")
                                    .font(.headline)
                                    .foregroundStyle(.txtVibrantSecondary)
                                Spacer()
                            }
                            
                            if let uiImage = UIImage(data: first.imgData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipped()
                                    .cornerRadius(10.0)
                                    .onTapGesture {
                                        navigationManager.push(to: .childAlbumDetail(photo: first))
                                    }
                            }
                            
                            Text(first.uploadDate.toKR())
                                .font(.subheadline)
                            
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            Text("충전 기록")
                                .font(.headline)
                                .foregroundStyle(.txtVibrantSecondary)
                        }
                        .padding(.horizontal, 16)
                        
                        LazyVGrid(columns: columnLayout, spacing: 3) {
                            ForEach(photoForSwiftDatas.dropFirst()) { photo in
                                if let uiImage = UIImage(data: photo.imgData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fill)
                                        .clipped()
                                        .onTapGesture {
                                            navigationManager.push(to: .childAlbumDetail(photo: photo))
                                        }
                                }
                            }
                        }
                    }
                    
                }
                .refreshable {
                    Task {
                        await didRefresh()
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
            } else {
                Text("아직 업로드된 사진이 없어요.")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChildAlbumView(
            user: UserForSwiftData(name: "", role: .child, email: ""),
            didRefresh: {}
        )
        .environment(NavigationManager())
        .preferredColorScheme(.dark)
        .navigationTitle("앨범")
    }
}
