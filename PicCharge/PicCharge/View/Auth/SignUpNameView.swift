//
//  SignUpNameView.swift
//  PicCharge
//
//  Created by 이상현 on 5/21/24.
//

import SwiftUI
import FirebaseAuth

struct SignUpNameView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(UserViewModel.self) var userVM

    @State private var name: String = ""
    @State private var isLoading: Bool = false
    
    private let email: String
    private let password: String
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("이름을 입력해주세요")
                .font(.title2.bold())
                .foregroundStyle(.txtPrimaryDark)
            
                TextField("이름을 입력해주세요", text: $name)
                    .autocapitalization(.none)
                    .foregroundStyle(.txtPrimaryDark)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(.bgPrimaryElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
            Spacer()
            
            FilledBtn(text: "다음 단계",
                      isActive: .init(get: { name.count >= 2 }, set: { _ in }),
                      isLoading: $isLoading) {
                
                isLoading = true
                
                Task.detached {
                    let isAvailable = await userVM.checkNameAvailable(name: name)
                    
                    await MainActor.run {
                        isLoading = false
                        
                        if isAvailable {
                            navigationManager.push(to: .signUpRole(name: name, email: email, password: password))
                        } else {
                            name = ""
                        }
                    }
                }
            }
        }
        .padding(.top, 40)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .navigationTitle("이름 설정")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // 현재 로그인한 사용자가 Apple 로그인인지 확인
            let isAppleUser = Auth.auth().currentUser?.providerData.contains(where: { $0.providerID == "apple.com" }) ?? false
            
            if isAppleUser && name.isEmpty {
                let appleName = userVM.tempAppleFullName.isEmpty ? "사용자" : userVM.tempAppleFullName
                name = appleName
            }
        }
    }
}

#Preview {
    SignUpNameView(email: "", password: "")
        .injectDIContainer()
        .preferredColorScheme(.dark)
}
