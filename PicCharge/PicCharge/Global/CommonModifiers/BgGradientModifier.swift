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
            .frame(height: 470)
            
            LinearGradient(
                gradient: Gradient(colors: [Color.bgPrimary.opacity(0), Color.bgPrimary]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 470)
        }
        .ignoresSafeArea()
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
