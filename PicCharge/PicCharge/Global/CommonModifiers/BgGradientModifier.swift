//
//  BgGradientModifier.swift
//  PicCharge
//
//  Created by 남유성 on 1/12/25.
//

import SwiftUI

struct BgGradientModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            Color.bgPrimary.ignoresSafeArea()
            
            LinearGradient(
                gradient: Gradient(colors: [Color.bgGreenFrom, Color.bgGreenTo]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .ignoresSafeArea()
            
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.bgPrimary]),
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        }
        .overlay {
            content
        }
    }
}

extension View {
    func bgGradient() -> some View {
        modifier(BgGradientModifier())
    }
}

#Preview {
    Color.clear
        .ignoresSafeArea()
        .bgGradient()
}
