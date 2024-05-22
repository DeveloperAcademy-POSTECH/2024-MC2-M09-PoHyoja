//
//  LoadingView.swift
//  PicCharge
//
//  Created by 김병훈 on 5/21/24.
//

import SwiftUI

struct LoadingView: View {
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
                LottieView(jsonName: "BatteryLoading", loopMode: .loop)
                    .frame(width: 200, height: 200)  // Adjust the frame size as needed
            }
        }
    }
}
#Preview {
    LoadingView()
}

