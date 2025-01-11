//
//  GlobalAlert.swift
//  PicCharge
//
//  Created by 남유성 on 1/11/25.
//

import SwiftData

@Observable
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
