//
//  LoginView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct LoginView: View {
    @Environment(NavigationManager.self) var navigationManager
    @ObservedObject var viewModel = UsersViewModel()
    
    @State private var userEmail: String = ""
    @State private var userRole: ServerRole = .parent
    
    var body: some View {
        NavigationView {
            VStack {
                Text("로그인/회원가입 화면")
                List(viewModel.users) { user in
                    VStack(alignment: .leading) {
                        Text(user.email)
                            .font(.headline)
                        Text(user.id!)
                            .font(.caption2)
                        Text(user.role?.rawValue ?? "")
                            .font(.caption)
                    }
                }
                .navigationTitle("Users")
                
                VStack {
                    TextField("Email", text: $userEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Picker("Role", selection: $userRole) {
                        ForEach(ServerRole.allCases, id: \.self) { role in
                            Text(role.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    Button(action: {
                        let newUser = ServerUser(
                            id: nil,
                            role: userRole,
                            email: userEmail,
                            uploadCycle: userRole == .child ? 3 : nil
                        )
                        viewModel.addUser(user: newUser)
                    }) {
                        Text("Add User")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                }
                Button("애플 로그인") {
                    navigationManager.push(to: .selectRole)
                }
            }
            .onAppear {
                viewModel.fetchUsers()
            }
        }
    }
}


#Preview {
    LoginView()
        .environment(NavigationManager())
}


