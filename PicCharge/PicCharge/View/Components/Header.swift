//
//  Header.swift
//  PicCharge
//
//  Created by Woowon Kang on 10/9/24.
//

import SwiftUI

struct Header: View {
    var title: String
    
    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(title)
                    .font(.largeTitle.bold())
                    
                Spacer()
            }
            .padding(.horizontal, 16)
            
            Divider()
                .padding(.bottom, 10)
        }
        .padding(.top, 44)
    }
}

#Preview {
    VStack {
        Header("픽-챠!")
        
        Spacer()
    }
    .preferredColorScheme(.dark)
}
