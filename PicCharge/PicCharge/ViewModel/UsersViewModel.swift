//
//  UsersViewModel.swift
//  PicCharge
//
//  Created by 이상현 on 5/18/24.
//

import Foundation

class UsersViewModel: ObservableObject {
    @Published var users = [ServerUser]()
    private var firestoreService = FirestoreService()
    
    func fetchUsers() {
        firestoreService.fetchUsers { [weak self] (users, error) in
            if let error = error {
                print("Error fetching users: \(error)")
                return
            }
            
            self?.users = users ?? []
        }
    }
    
    func addUser(user: ServerUser) {
        firestoreService.addUser(user: user) { result in
            switch result {
            case .success:
                self.fetchUsers()
            case .failure(let error):
                print("Error adding user: \(error)")
            }
        }
    }
}
