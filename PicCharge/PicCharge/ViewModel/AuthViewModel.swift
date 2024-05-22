//
//  AuthViewModel.swift
//  PicCharge
//
//  Created by 이상현 on 5/21/24.
//

import SwiftUI
import Firebase

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var user: User?

    init() {
        self.user = self.convertFirebaseUser(user: Auth.auth().currentUser)
        self.isLoggedIn = self.user != nil
        
        Auth.auth().addStateDidChangeListener { auth, firebaseUser in
            self.user = self.convertFirebaseUser(user: firebaseUser)
            self.isLoggedIn = firebaseUser != nil
        }
    }

    func login(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error)
                return
            }
            self.user = self.convertFirebaseUser(user: authResult?.user)
            self.isLoggedIn = true
            completion(nil)
        }
    }

    func signUp(name: String, email: String, password: String, role: Role, completion: @escaping (Error?) -> Void) {
        Task {
            do {
                if try await FirestoreService.shared.checkUserExists(userName: name) {
                    throw FirestoreServiceError.userAlreadyExists
                }
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        completion(error)
                        return
                    }
                    guard let firebaseUser = authResult?.user else {
                        completion(FirestoreServiceError.userNotFound)
                        return
                    }
                    let newUser = User(id: firebaseUser.uid, name: name, role: role, email: email)
                    Task {
                        do {
                            try await FirestoreService.shared.addUser(user: newUser)
                            self.user = newUser
                            self.isLoggedIn = true
                            completion(nil)
                        } catch {
                            completion(error)
                        }
                    }
                }
            } catch {
                completion(error)
            }
        }
    }

    func signOut(completion: @escaping (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
            self.user = nil
            completion(nil)
        } catch let signOutError as NSError {
            completion(signOutError)
        }
    }
    
    func deleteUser(completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(FirestoreServiceError.userNotFound)
            return
        }
        
        Task {
            do {
                // Delete the user from Firestore
                if let userId = self.user?.id {
                    try await FirestoreService.shared.deleteUser(user: self.user!)
                }
                // Delete the Firebase Auth user
                try await user.delete()
                self.isLoggedIn = false
                self.user = nil
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }


    private func convertFirebaseUser(user: FirebaseAuth.User?) -> User? {
        guard let user = user else { return nil }
        return User(id: user.uid, name: "", role: .child, email: user.email ?? "")
    }
}
