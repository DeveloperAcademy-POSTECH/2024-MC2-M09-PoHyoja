//
//  ParentWidgetBundle.swift
//  ParentWidget
//
//  Created by 김도현 on 5/19/24.
//

import WidgetKit
import SwiftUI

@main
struct ParentWidgetBundle: WidgetBundle {
    var body: some Widget {
        ChildWidget()
        ParentWidget()
    }
}
