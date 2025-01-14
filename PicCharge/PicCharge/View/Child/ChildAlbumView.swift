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
    @Environment(UserViewModel.self) var userVM
    @Environment(PhotoViewModel.self) var photoVM
    
    //geometryReader로 3등분
    let columnLayout = [
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3)
    ]
    
    var body: some View {
        Group {
            if let mainPhoto = photoVM.photos.first {
                ScrollView {
                    Header("앨범")
                    
                    VStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("최근 업로드 사진")
                                    .font(.headline)
                                    .foregroundStyle(.txtVibrantSecondary)
                                Spacer()
                            }
                            
                            SquareImage(data: mainPhoto.imgData)
                                .cornerRadius(10.0)
                                .onTapGesture {
                                    navigationManager.push(to: .childAlbumDetail(photo: mainPhoto))
                                }
                            
                            Text(mainPhoto.uploadDate.toKR())
                                .font(.subheadline)
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            Text("충전 기록")
                                .font(.headline)
                                .foregroundStyle(.txtVibrantSecondary)
                        }
                        .padding(.horizontal, 16)
                        
                        LazyVGrid(columns: columnLayout, spacing: 3) {
                            ForEach(photoVM.photos.dropFirst()) { photo in
                                SquareImage(data: photo.imgData)
                                    .onTapGesture {
                                        navigationManager.push(to: .childAlbumDetail(photo: photo)
                                        )
                                    }
                            }
                        }
                    }
                    
                }
            } else {
                GeometryReader { geometry in
                    ScrollView {
                        Text("아직 업로드된 사진이 없어요.")
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
            }
        }
        .refreshable {
            Task {
                try await photoVM.syncPhoto(of: userVM.user?.name ?? "자식")
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChildAlbumView()
            .injectDIContainer()
            .preferredColorScheme(.dark)
    }
}
