//
//  ParentAlbumView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI
import SwiftData

struct ParentAlbumView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    @Query var photos: [PhotoForSwiftData]
    
    //geometryReader로 3등분
    let columnLayout = [
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3)
    ]
    
    var body: some View {
        Group {
            if let last = photos.last {
                ScrollView {
                    Divider()
                        .padding(.bottom, 10)
                    
                    VStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("최근 업로드 사진")
                                .font(.headline)
                                .foregroundStyle(.txtVibrantSecondary)
                            
                            if let uiImage = UIImage(data: last.imgData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipped()
                                    .cornerRadius(10.0)
                                    .onTapGesture {
                                        navigationManager.push(to: .parentAlbumDetail(photo: last))
                                    }
                            }
                            
                            Text(last.uploadDate.toKR())
                                .font(.subheadline)
                            
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            Text("충전 기록")
                                .font(.headline)
                                .foregroundStyle(.txtVibrantSecondary)
                        }
                        .padding(.horizontal, 16)
                        
                        LazyVGrid(columns: columnLayout, spacing: 3) {
                            ForEach(photos) { photo in
                                if let uiImage = UIImage(data: photo.imgData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fill)
                                        .clipped()
                                        .onTapGesture {
                                            navigationManager.push(to: .parentAlbumDetail(photo: photo))
                                        }
                                }
                            }
                        }
                    }
                    
                }
            } else {
                Text("아직 업로드된 사진이 없어요.")
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("앨범")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    navigationManager.push(to: .setting(role: .parent))
                } label: {
                    Icon.setting
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ParentAlbumView()
            .environment(NavigationManager())
            .preferredColorScheme(.dark)
    }
}
