//
//  AppNavigationView.swift
//  PicCharge
//
//  Created by 남유성 on 12/30/24.
//

import SwiftUI

struct AppNavigationView: View {
    @Environment(NavigationManager.self) var navigationManager: NavigationManager
    
    var body: some View {
        @Bindable var navigationManager = navigationManager
        
        NavigationStack(path: $navigationManager.path) {
            ContentView()
                .navigationDestination(for: PathType.self) { path in
                    path.NavigatingView()
                }
        }
    }
}

#Preview {
    AppNavigationView()
        .injectDIContainer()
}
