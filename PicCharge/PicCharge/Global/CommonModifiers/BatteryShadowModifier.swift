//
//  BatteryShadowModifier.swift
//  PicCharge
//
//  Created by 남유성 on 5/18/24.
//

import SwiftUI

struct BatteryShadowModifier: ViewModifier {
    var color: Color
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        color.gradient.shadow(
                            .inner(
                                color: Color.white.opacity(0.5),
                                radius: 3,
                                x: 0,
                                y: 4
                            )
                        )
                    )
                    .shadow(
                        color: color.opacity(0.5),
                        radius: CGFloat(6),
                        x: CGFloat(0),
                        y: CGFloat(4)
                    )
            )
    }
}

extension View {
    /// 배터리 shadow 처리 modifier
    /// - Parameter color: 배터리 색상 Color 값
    /// - Returns: 색상 처리가 된 Background 뷰
    ///
    /// 아래의 예시처럼 ZStack에 Background로 배터리를 추가하는 방식으로 사용하시면 됩니다.
    /// 아래는 배터리 위에 추가적인 View를 추가하는 예시입니다.
    ///
    /// ```swift
    /// struct ColorTestView: View {
    ///     var body: some View {
    ///         VStack {
    ///             ZStack {
    ///                Color.clear.batteryShadow(color: .battery100)
    ///
    ///                Text("배터리 100%")
    ///            }
    ///            .padding(20)
    ///
    ///            ZStack {
    ///                Color.clear.batteryShadow(color: .battery50)
    ///
    ///                Text("배터리 50%")
    ///            }
    ///            .padding(20)
    ///
    ///            ZStack {
    ///                Color.clear.batteryShadow(color: .battery10)
    ///
    ///                Text("배터리 10%")
    ///            }
    ///            .padding(20)
    ///        }
    ///        .foregroundStyle(.txtPrimary)
    ///        .font(.largeTitle.bold())
    ///        .background(Color(UIColor.systemGray5))
    ///     }
    /// }
    /// ```
    func batteryShadow(color: Color) -> some View {
        modifier(BatteryShadowModifier(color: color))
    }
}
