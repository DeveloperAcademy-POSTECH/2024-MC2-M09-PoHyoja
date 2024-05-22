//
//  UserManager.swift
//  PicCharge
//
//  Created by 이상현 on 5/20/24.
//

import Foundation

class UserManager: ObservableObject {
    @Published var user: User? {
        didSet {
            saveUserToDefaults()
        }
    }
    
    init() {
        loadUserFromDefaults()
    }
    
    // 현재 사용자의 정보를 로컬에 저장한다.
    // TODO: 추후에 앱과 위젯에서 같이 사용하는 UserDefaults.shared를 이용할 예정
    private func saveUserToDefaults() {
        guard let user = user else { return }
        do {
            let data = try JSONEncoder().encode(user)
            UserDefaults.standard.set(data, forKey: "currentUser")
        } catch {
            print("Failed to save user: \(error)")
        }
    }
    
    // 현재 사용자의 정보를 로컬에서 가져온다.
    private func loadUserFromDefaults() {
        guard let data = UserDefaults.standard.data(forKey: "currentUser") else { return }
        print("로컬에서 가져온 데이터: \(data)")
        do {
            let user = try JSONDecoder().decode(User.self, from: data)
            self.user = user
            print(user.id! + "불러옴")
        } catch {
            print("Failed to load user: \(error)")
        }
    }
    
    /// 사용자의 정보를 초기화한다.
    func clearUser() {
        user = nil
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    /// 로그인 상태인지 확인한다.
    func isLoggedIn() -> Bool {
        return user != nil
    }

//  테스트용 로컬 데이터 삭제 코드
    func resetUserDefaults() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
}
