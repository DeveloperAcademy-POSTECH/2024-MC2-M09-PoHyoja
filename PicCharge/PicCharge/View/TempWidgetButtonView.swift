//
//  TempWidgetButtonView.swift
//  PicCharge
//
//  Created by 김도현 on 5/20/24.
//

import SwiftUI
import WidgetKit

struct TempWidgetButtonView: View {
    @State private var imageNum: Int = 0
    
    var body: some View {
        AsyncImage(url: URL(string: "https://picsum.photos/id/\(200 + (imageNum % 4))/200/300")) { image in
            image.resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            ProgressView()
        }
        
        Button("이미지 업데이트") {
            imageNum += 1
            let urlString = "https://picsum.photos/id/\(200 + (imageNum % 4))/200/300"

            // MARK: - UserDefault에 저장
            UserDefaults.shared.set(urlString, forKey: "urlString")
            
            // MARK: - 타임라인 리로드
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

#Preview {
    TempWidgetButtonView()
}
