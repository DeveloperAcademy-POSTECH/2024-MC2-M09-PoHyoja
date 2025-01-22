//
//  TitleView.swift
//  PicCharge
//
//  Created by Woowon Kang on 10/9/24.
//

import SwiftUI

struct TitleView: View {
    var title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 44)
    }
}
