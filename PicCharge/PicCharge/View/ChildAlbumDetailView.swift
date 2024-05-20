//
//  ChildAlbumDetailView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct ChildAlbumDetailView: View {
    //좋아요 개수를 변수로 생성했습니다.
    var likeCount = 1234
    //삭제시 액션시트 뜨게 하기위한 변수입니다.
    @State var showingDeleteSheet = false
    //Sharelink구현을 위한 임시 url입니다.
    private let url = URL(string: "https://github.com/DeveloperAcademy-POSTECH/2024-MC2-M09-PoHyoja")!
    
    var today = Date()
    
    var body: some View {
        NavigationStack{
            GeometryReader {geometry in
                VStack{
                    Spacer()
                    AsyncImageView(urlString: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQsNICnidsWi7x-UmXHlkEz-8VUeKwmJSg86Xli4i-26A&s")
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                    //좋아요 버튼과 숫자를 VStack으로 묶었습니다.
                    VStack(spacing: 4){
                        Button(action: {
                            print("좋아요 추가")
                        }, label: {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                        })
                        Text("\(likeCount)개")
                            .font(.body)
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    }
                    .padding(.vertical, 80)
                }
                Spacer()
            }
            //제목에 들어갈 현재 일자입니다.
            .navigationTitle("\(today, formatter: TempChildAlbumView.dateformat)")
            .navigationBarTitleDisplayMode(.inline)
            //툴바에 메뉴버튼을 구현했습니다.
            .toolbar{
                Menu{
                    Button(action: {print("문의하기")}) {
                        Label("문의하기", systemImage: "info.circle")
                    }
                    //공유버튼 ShareLink입니다.
                    ShareLink(item: url){
                        Label("공유하기", systemImage: "square.and.arrow.up")
                    }
                    //삭제버튼은 메뉴 안에 액션시트 하나 더 넣었습니다.
                    Button(role: .destructive, action: {self.showingDeleteSheet = true}) {
                        Label("삭제하기", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .confirmationDialog("타이틀", isPresented: $showingDeleteSheet) {
                      Button("삭제", role: .destructive) {print("삭제완료")}
                      Button("취소", role: .cancel) {}
                    }
            }
        }
    }
}


#Preview {
    ChildAlbumDetailView()
}

