//
//  String+.swift
//  PicCharge
//
//  Created by 남유성 on 1/15/25.
//

import Foundation

extension String {
    var isValidEmail: Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
}
