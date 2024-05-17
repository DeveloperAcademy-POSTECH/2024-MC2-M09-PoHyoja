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
                            
                                Text("회원탈퇴")
                                    .foregroundStyle(.red)
                            
                        }
                        
                    }
                    .padding(.top, 36)
                    .navigationTitle("설정")
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
