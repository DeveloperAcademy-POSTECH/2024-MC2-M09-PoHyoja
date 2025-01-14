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
            .transition(.opacity.animation(.easeInOut(duration: 1)))
    }
}

#Preview {
    BuggungLoadingView()
        .preferredColorScheme(.dark)
}
