//
//  GlobalAlert.swift
//  PicCharge
//
//  Created by 남유성 on 1/11/25.
//

import SwiftData
import SwiftUI

@MainActor @Observable
final class GlobalAlert {
    static let shared = GlobalAlert()
    
    var isAlert: Bool = false
    var alertMessage: String?
    
    private init() {}
}

extension GlobalAlert {
    func show(message: String? = nil) {
        alertMessage = message
        isAlert = true
    }
    
    func hide() {
        isAlert = false
        alertMessage = nil
    }
}

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
