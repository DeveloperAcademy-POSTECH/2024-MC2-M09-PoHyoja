//
//  TempSettingView.swift
//  PicCharge
//
//  Created by Woowon Kang on 5/17/24.
//

import SwiftUI

// Role에 따라 '부모', '자식' 표기할 수 있게 만들기

struct TempSettingView: View {
    
    @State var version = "1.0.0"
    @State private var showingLogoutActionSheet = false
    @State private var showingWithdrawActionSheet = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                    List {
                        Section {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("연결된 계정")
                                    Text("iamdaddy")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("부모")
                                    .foregroundStyle(.secondary)
                            }
                            HStack{
                                VStack(alignment: .leading) {
                                    Text("김김김")
                                    Text("imyourson")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("자식")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Section {
                            Text("서비스 약관 / 개인정보 방침")
                            
                            Text("로그아웃")
                                .onTapGesture {
                                    showingLogoutActionSheet = true
                                }
                            
                            Text("회원탈퇴")
                                .onTapGesture {
                                    showingWithdrawActionSheet = true
                                }
                                .foregroundStyle(.red)
                            
                        }
                        
                    }
                    .padding(.top, 36)
                    .navigationTitle("설정")
            }
            .confirmationDialog("로그아웃 하시겠습니까?", isPresented: $showingLogoutActionSheet, titleVisibility: .visible) {
                VStack {
                    Button("로그아웃", role: .destructive) {}
                    Button("Cancel", role: .cancel) {}
                }
                
            }
            .confirmationDialog("회원을 탈퇴하시겠습니까? \n 탈퇴하면 되돌릴 수 없고, 저희가 슬퍼요.", isPresented: $showingWithdrawActionSheet, titleVisibility: .visible) {
                VStack {
                    Button("탈퇴하기", role: .destructive) {}
                    Button("로그아웃", role: .destructive) {}
                    Button("Cancel", role: .cancel) {}
                }
                
            }
            
            Text("version. \(version)")
                .foregroundStyle(.secondary)
                .padding(.top, 200)
        }
        
    }
}

#Preview {
    TempSettingView()
}
