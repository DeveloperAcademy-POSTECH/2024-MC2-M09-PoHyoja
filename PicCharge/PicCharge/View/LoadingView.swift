//
//  LoadingView.swift
//  PicCharge
//
//  Created by 김병훈 on 5/21/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            LottieView(jsonName: "TestAnimation", loopMode:.loop)
                .frame(width: 200, height: 200)  // Adjust the frame size as needed
        }
    }
}

#Preview {
    LoadingView()
}

