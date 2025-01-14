//
//  FilledBtn.swift
//  PicCharge
//
//  Created by 남유성 on 1/15/25.
//

import SwiftUI

struct FilledBtn: View {
    @Binding var isActive: Bool
    @Binding var isLoading: Bool
    let text: String
    let action: () -> Void

    init(
        text: String,
        isActive: Binding<Bool> = .constant(true),
        isLoading: Binding<Bool> = .constant(false),
        action: @escaping () -> Void
    ) {
        self.text = text
        self._isActive = isActive
        self._isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(text)
                        .fontWeight(.black)
                        .foregroundStyle(.txtPrimaryDark)
                }
                
                Spacer()
            }
        }
        .frame(height: 54)
        .background(isActive ? Color.green : Color.gray)
        .animation(.default, value: isActive)
        .animation(.default, value: isLoading)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .disabled(!isActive || isLoading)
    }
}

#Preview {
    @Previewable @State var isActive1 = true
    @Previewable @State var isLoading1 = false
    @Previewable @State var isActive2 = false
    @Previewable @State var isLoading2 = true

    VStack(spacing: 16) {
        FilledBtn(text: "확인",
                  isActive: $isActive1,
                  isLoading: $isLoading1
        ) {
            print("Button 1 tapped!")
        }

        FilledBtn(text: "확인", isActive: $isActive2, isLoading: $isLoading2) {
            print("Button 2 tapped!")
        }
        
        Button("Toggle Button 1 State") {
            isActive1.toggle()
        }
        
        Button("Toggle Button 1 loading") {
            isLoading1.toggle()
        }
    }
    .padding()
    .preferredColorScheme(.dark)
}
