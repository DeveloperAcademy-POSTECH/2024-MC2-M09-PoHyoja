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
        ZStack {
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
                LottieView(jsonName: "BuggungEnd", loopMode: .playOnce)
            }
        }
        .ignoresSafeArea()
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
