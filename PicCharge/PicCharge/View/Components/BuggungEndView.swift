//
//  BuggungEndView.swift
//  PicCharge
//
//  Created by Woowon Kang on 5/25/24.
//

import SwiftUI

struct BuggungEndView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    var body: some View {
        LottieView(jsonName: "BuggungEnd", loopMode: .playOnce)
            .ignoresSafeArea()
            .bgGradient()
            .navigationBarBackButtonHidden(true)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    navigationManager.popToRoot()
                }
            }
    }
}

#Preview {
    BuggungEndView()
        .environment(NavigationManager())
        .preferredColorScheme(.dark)
}
