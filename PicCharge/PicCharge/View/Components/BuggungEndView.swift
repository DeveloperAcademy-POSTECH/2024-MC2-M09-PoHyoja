//
//  BuggungEndView.swift
//  PicCharge
//
//  Created by Woowon Kang on 5/25/24.
//

import SwiftUI

struct BuggungEndView: View {
    var body: some View {
        LottieView(jsonName: "BuggungEnd", loopMode: .playOnce)
            .bgGradient()
            .ignoresSafeArea()
            .transition(.opacity.animation(.easeInOut(duration: 1)))
    }
}

#Preview {
    BuggungEndView()
        .preferredColorScheme(.dark)
}
