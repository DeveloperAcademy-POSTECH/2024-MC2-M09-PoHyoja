//
//  BuggungLoadingView.swift
//  PicCharge
//
//  Created by Woowon Kang on 5/24/24.
//

import SwiftUI

struct BuggungLoadingView: View {
    var body: some View {
        LottieView(jsonName: "BuggungLoading", loopMode: .loop)
            .frame(width: 200, height: 200)
            .bgGradient()
    }
}

#Preview {
    BuggungLoadingView()
        .preferredColorScheme(.dark)
}
