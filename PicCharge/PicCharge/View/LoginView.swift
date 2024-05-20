//
//  LoginView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct LoginView: View {
    @Environment(NavigationManager.self) var navigationManager
    @State private var userId: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            Text("회원가입 화면")
                .font(.largeTitle)
                .padding()
            
            TextField("아이디 입력", text: $userId)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("회원가입") {
                Task {
                    await login()
                }
            }
            .padding()
            .buttonStyle(.borderedProminent)
            .disabled(userId.isEmpty)
        }
        .padding()
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func login() async {
        do {
            let userExists = try await FirestoreService.shared.checkUserExists(userId: userId)
            
            if userExists {
                alertMessage = "아이디가 이미 존재합니다. 다른 아이디를 입력해주세요."
                showingAlert = true
            } else {
                navigationManager.push(to: .selectRole(userId: userId))
            }
        } catch {
            alertMessage = "An error occurred: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    LoginView()
        .environment(NavigationManager())
}


