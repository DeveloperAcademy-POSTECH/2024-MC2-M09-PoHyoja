//
//  SelectRoleForSignUpView.swift
//  PicCharge
//
//  Created by 남유성 on 5/23/24.
//

import SwiftUI
import FirebaseAuth

struct SelectRoleForSignUpView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    @State var selectedRole: Role = .child
    @State private var isNetworking: Bool = false
    @State private var isShowingAlert: Bool = false
    
    private let name: String
    private let email: String
    private let password: String
        
    var isSignUpAvailable: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty
    }
    
    init(name: String, email: String, password: String) {
        self.name = name
        self.email = email
        self.password = password
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("당신의 역할을 선택해주세요")
                    .font(.title2.bold())
                    .foregroundStyle(.txtPrimaryDark)
                    .padding(.top, 40)
                
                Spacer()
            }
            
            Spacer()
            
            HStack(spacing: 60) {
                VStack(spacing: 10) {
                    ZStack {
                        Image("자식")
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
                
                VStack(spacing: 10) {
                    ZStack {
                        Image("부모")
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
                
            }
            
            Spacer()
            Spacer()
            
            Button {
                Task {
                    isNetworking = true
                    await signUp(name: name, email: email, password: password, role: selectedRole)
                    isNetworking = false
                }
            } label: {
                ZStack {
                    isSignUpAvailable ? Color.green : Color.gray
                    
                    if isNetworking {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("회원가입")
                            .bold()
                            .foregroundStyle(.txtPrimaryDark)
                    }
                }
            }
            .frame(height: 54)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .disabled(isNetworking)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .navigationTitle("역할 선택")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $isShowingAlert) {
            Alert(
                title: Text("Error"),
                message: Text("기본 정보 문제로 회원가입 실패!"),
                dismissButton: Alert.Button.default(Text("OK")) {
                    navigationManager.pop()
                }
            )
        }
    }
}

extension SelectRoleForSignUpView {
    func signUp(name: String, email: String, password: String, role: Role) async {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = authResult.user
            
            let newUser = User(id: user.uid, name: name, role: role, email: email, connectedTo: [])
            try await FirestoreService.shared.addUser(user: newUser)
            
            navigationManager.popToRoot()
        } catch {
            print("회원 가입 실패")
            isShowingAlert = true
        }
    }
}

#Preview {
    SelectRoleForSignUpView(name: "", email: "", password: "")
        .environment(NavigationManager())
        .preferredColorScheme(.dark)
}
