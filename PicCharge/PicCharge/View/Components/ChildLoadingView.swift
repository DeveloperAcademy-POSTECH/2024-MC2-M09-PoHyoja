//
//  LoadingView.swift
//  PicCharge
//
//  Created by 김병훈 on 5/21/24.
//

import SwiftUI

struct ChildLoadingView: View {
    var body: some View {
        LottieView(jsonName: "BatteryLoading", loopMode: .loop)
            .frame(width: 200, height: 200)  // Adjust the frame size as needed
            .bgGradient()
            .navigationBarBackButtonHidden(true)
    }
}
#Preview {
    ChildLoadingView()
}

