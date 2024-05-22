//
//  ParentAlbumView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct ParentAlbumView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    @State private var photos: [Photo] = Photo.mockup
    
    //geometryReader로 3등분
    let columnLayout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        Group {
            if let last = photos.last {
                GeometryReader { geometry in
                    ScrollView {
                        Divider()
                            .padding(.bottom, 10)
                        
                        VStack(spacing: 8) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("최근 업로드 사진")
                                    .font(.headline)
                                    .foregroundStyle(.txtVibrantSecondary)
                                
                                AsyncImageView(urlString: last.urlString) { imgData in
                                    navigationManager.push(to: .parentAlbumDetail(photo: last, imgData: imgData))
                                }
                                .frame(width: max(0, geometry.size.width - 32), height: max(0, geometry.size.width - 32))
                                .clipped()
                                .cornerRadius(10.0)
                                
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
                                    AsyncImageView(urlString: photo.urlString) { imgData in
                                        navigationManager.push(to: .parentAlbumDetail(photo: last, imgData: imgData))
                                    }
                                    .frame(width: max(0, geometry.size.width - 3) / 3, height: max(0, geometry.size.width - 3) / 3 )
                                    .clipped()
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
