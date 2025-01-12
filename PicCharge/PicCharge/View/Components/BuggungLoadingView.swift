//
//  BuggungLoadingView.swift
//  PicCharge
//
//  Created by Woowon Kang on 5/24/24.
//

import SwiftUI

struct BuggungLoadingView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    var body: some View {
        LottieView(jsonName: "BuggungLoading", loopMode: .loop)
            .frame(width: 200, height: 200)
            .bgGradient()
            .navigationBarBackButtonHidden(true)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    navigationManager.popToRoot()
                }
            }
    }
}

#Preview {
    BuggungLoadingView()
        .environment(NavigationManager())
        .preferredColorScheme(.dark)
}
