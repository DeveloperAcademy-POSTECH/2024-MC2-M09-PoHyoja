//
//  SignUpRoleView.swift
//  PicCharge
//
//  Created by 남유성 on 5/23/24.
//

import SwiftUI
import FirebaseAuth

struct SignUpRoleView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(UserViewModel.self) var userVM
    
    @State var selectedRole: Role = .child
    @State private var isLoading: Bool = false
    
    private let name: String
    private let email: String
    private let password: String
        
    
    init(name: String, email: String, password: String) {
        self.name = name
        self.email = email
        self.password = password
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("당신의 역할을 선택해주세요")
                .font(.title2.bold())
                .foregroundStyle(.txtPrimaryDark)
            
            Spacer()
            
            HStack {
                Spacer()
                
                VStack(spacing: 10) {
                    ZStack {
                        Image("Child")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(Circle())
                        
                        if selectedRole == .child {
                            Circle()
                                .stroke(Color.accent, lineWidth: 4)
                                .frame(width: 100)
                                .transition(.identity)
                        }
                    }
                    .frame(width: 100)
                    
                    Text("자식")
                        .font(.title3)
                        .foregroundStyle(.txtPrimaryDark)
                }
                .onTapGesture {
                    selectedRole = .child
                }
                
                Spacer()
                
                VStack(spacing: 10) {
                    ZStack {
                        Image("Parent")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(Circle())
                        
                        if selectedRole == .parent {
                            Circle()
                                .stroke(Color.accent, lineWidth: 4)
                                .frame(width: 100)
                                .transition(.identity)
                        }
                    }
                    .frame(width: 100)
                    
                    Text("부모")
                        .font(.title3)
                        .foregroundStyle(.txtPrimaryDark)
                }
                .onTapGesture {
                    selectedRole = .parent
                }
                
                Spacer()
            }
            
            Spacer()
            Spacer()
            
            FilledBtn(text: "회원가입", isLoading: $isLoading) {
                isLoading = true
                
                Task.detached {
                    do {
                        try await userVM.signUp(name: name, email: email, password: password, role: selectedRole)
                        
                        await MainActor.run { navigationManager.pop(to: .emailLogin) }
                        
                    } catch {
                        await GlobalAlert.shared.show(message: email.description)
                    }
                    await MainActor.run { isLoading = false }
                }
            }
        }
        .padding(.top, 40)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .navigationTitle("역할 선택")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SignUpRoleView(name: "", email: "", password: "")
        .injectDIContainer()
        .preferredColorScheme(.dark)
}
