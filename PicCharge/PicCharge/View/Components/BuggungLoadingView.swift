//
//  BuggungLoadingView.swift
//  PicCharge
//
//  Created by Woowon Kang on 5/24/24.
//

import SwiftUI

struct BuggungLoadingView: View {
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                LottieView(jsonName: "BuggungLoading", loopMode: .loop)
                    .frame(width: 200, height: 200)
                    .offset(y: -12)
                
            } else {
                LottieView(jsonName: "BuggungEnd", loopMode: .playOnce)
                    .ignoresSafeArea()
            }
        }
        .transition(.opacity.animation(.easeInOut(duration: 1)))
        .bgGradient()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isLoading = false
            }
        }
    }
}

#Preview {
    BuggungLoadingView()
        .preferredColorScheme(.dark)
}
