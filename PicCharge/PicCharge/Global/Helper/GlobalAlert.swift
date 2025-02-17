//
//  GlobalAlert.swift
//  PicCharge
//
//  Created by 남유성 on 1/11/25.
//

import SwiftData
import SwiftUI

struct Selection {
    var title: String
    var message: String
    var selection: String
    var action: () -> Void
}

@MainActor @Observable
final class GlobalAlert {
    static let shared = GlobalAlert()
    
    var isAlert: Bool = false
    var isSelectionAlert: Bool = false
    var selection: Selection?
    var alertMessage: String?
    
    private init() {}
}

extension GlobalAlert {
    func show(title: String,
              message: String,
              selection: String,
              action: @escaping () -> Void
    ) {
        self.selection = .init(title: title, message: message, selection: selection, action: action)
        isSelectionAlert = true
    }
    
    func show(message: String? = nil) {
        alertMessage = message
        isAlert = true
    }
    
    func hide() {
        isAlert = false
        isSelectionAlert = false
        alertMessage = nil
        selection = nil
    }
}

struct GlobalAlertModifier: ViewModifier {
    @Bindable private var globalAlert = GlobalAlert.shared
    
    func body(content: Content) -> some View {
        content
            .alert(isPresented: $globalAlert.isAlert) {
                Alert(
                    title: Text("알림"),
                    message: Text(globalAlert.alertMessage ?? "")
                )
            }
            .alert(isPresented: $globalAlert.isSelectionAlert) {
                Alert(title: Text(globalAlert.selection?.title ?? ""),
                      message: Text(globalAlert.selection?.message ?? ""),
                      primaryButton: .cancel(Text("취소하기")),
                      secondaryButton: .destructive(Text(globalAlert.selection?.selection ?? "" )) {
                    
                    globalAlert.selection?.action()
                })
            }
    }
}

extension View {
    func globalAlert() -> some View {
        modifier(GlobalAlertModifier())
    }
}
