//
//  TempChildAlbumView.swift
//  PicCharge
//
//  Created by 김병훈 on 5/17/24.
//

import SwiftUI

struct TempChildAlbumView: View {
    
    let columnLayout = Array(repeating: GridItem(), count: 3)
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
            ScrollView{
                VStack(alignment: .leading){
                    Text("최근 업로드 사진")
                        .font(.headline)
                    
                    AsyncImage(url: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQsNICnidsWi7x-UmXHlkEz-8VUeKwmJSg86Xli4i-26A&s")) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .cornerRadius(10.0)
                    Text("\(today, formatter: TempChildAlbumView.dateformat)")
                    
                    Divider()
                    
                    Text("충전 기록")
                    LazyVGrid(columns: columnLayout, spacing: 0) {
                        ForEach(photos) { photo in
                            AsyncImage(url: URL(string: photo.urlString)) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipped()
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                    .cornerRadius(8.0)
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
