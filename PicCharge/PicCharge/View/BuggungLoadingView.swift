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
        ZStack{
            VStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.bgGreen, Color.bgGreen.opacity(0)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 320)
                
                Spacer()
            }
            .ignoresSafeArea()
            VStack {
                LottieView(jsonName: "BuggungLoading", loopMode: .loop)
                    .frame(width: 200, height: 200)
            }
        }
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
}
