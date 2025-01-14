//
//  IconBtn.swift
//  PicCharge
//
//  Created by 남유성 on 1/13/25.
//

import SwiftUI

struct IconBtn: View {
    var icon: Image
    var size: CGFloat
    var action: () -> Void
    
    init(_ icon: Image, size: CGFloat = 48, action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            icon.resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
    }
}
