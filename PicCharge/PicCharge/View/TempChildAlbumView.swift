//
//  TempChildAlbumView.swift
//  PicCharge
//
//  Created by 김병훈 on 5/17/24.
//

import SwiftUI

struct TempChildAlbumView: View {
    
    //geometryReader로 3등분
    let columnLayout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    //끝도없이 내려가는거 확인해보기
    
    let photos = Photo.mockup
    
    //날짜형식을 위해 formatter를 만들어줍니다.
    static let dateformat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY년 M월 d일"
        return formatter
    }()
    var today = Date()
    
    var body: some View {
        NavigationStack{
            GeometryReader {geometry in
                ScrollView{
                    VStack(alignment: .leading, spacing: 8){
                        Text("최근 업로드 사진")
                            .font(.headline)
                        
                        AsyncImage(url: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQsNICnidsWi7x-UmXHlkEz-8VUeKwmJSg86Xli4i-26A&s")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                        } placeholder: {ProgressView()}
                        .frame(width: geometry.size.width , height: geometry.size.width)
                        .cornerRadius(10.0)
                        
                        Text("\(today, formatter: TempChildAlbumView.dateformat)")
                            .font(.subheadline)
                        Divider()
                            .padding(.vertical, 8)
                        Text("충전 기록")
                            .font(.headline)
            
                        LazyVGrid(columns: columnLayout, spacing: 3) {
                            ForEach(photos) { photo in
                                AsyncImage(url: URL(string: photo.urlString)) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: (geometry.size.width / 3), height: (geometry.size.width / 3))
                                        .clipped()
                                } placeholder: {ProgressView()}
                            }
                        }
                        .cornerRadius(8.0)
                        
                    }
                }
            }
            .padding()
            .navigationTitle("앨범")
            
        }
        
        
        
    }
    
}


#Preview {
    TempChildAlbumView()
}
