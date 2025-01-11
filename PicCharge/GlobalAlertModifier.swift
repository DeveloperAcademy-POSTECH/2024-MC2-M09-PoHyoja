//
//  GlobalAlertModifier.swift
//  PicCharge
//
//  Created by 남유성 on 1/11/25.
//

import SwiftUI

struct GlobalAlertModifier: ViewModifier {
    @Bindable private var globalAlert = GlobalAlert.shared
    
    func body(content: Content) -> some View {
        content
            .alert(isPresented: $globalAlert.isAlert) {
                Alert(
                    title: Text("Alert"),
                    message: Text(globalAlert.alertMessage ?? "")
                )
            }
    }
}

extension View {
    func globalAlert() -> some View {
        modifier(GlobalAlertModifier())
    }
}
