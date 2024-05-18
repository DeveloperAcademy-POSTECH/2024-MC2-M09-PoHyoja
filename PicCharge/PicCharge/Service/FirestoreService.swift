//
//  FirestoreService.swift
//  PicCharge
//
//  Created by 이상현 on 5/18/24.
//
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreService {
    private var db = Firestore.firestore()
    
    // ServerUser 데이터를 가져오는 함수
    func fetchUsers(completion: @escaping ([ServerUser]?, Error?) -> Void) {
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            let users = querySnapshot?.documents.compactMap { document -> ServerUser? in
                try? document.data(as: ServerUser.self)
            }
            completion(users, nil)
        }
    }
    
    // ServerConnectionRequest 데이터를 가져오는 함수
    func fetchConnectionRequests(completion: @escaping ([ServerConnectionRequest]?, Error?) -> Void) {
        db.collection("connectionRequests").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            let requests = querySnapshot?.documents.compactMap { document -> ServerConnectionRequest? in
                try? document.data(as: ServerConnectionRequest.self)
            }
            completion(requests, nil)
        }
    }
    
    // ServerConnection 데이터를 가져오는 함수
    func fetchConnections(completion: @escaping ([ServerConnection]?, Error?) -> Void) {
        db.collection("connections").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            let connections = querySnapshot?.documents.compactMap { document -> ServerConnection? in
                try? document.data(as: ServerConnection.self)
            }
            completion(connections, nil)
        }
    }
    
    // ServerPhoto 데이터를 가져오는 함수
    func fetchPhotos(completion: @escaping ([ServerPhoto]?, Error?) -> Void) {
        db.collection("photos").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            let photos = querySnapshot?.documents.compactMap { document -> ServerPhoto? in
                try? document.data(as: ServerPhoto.self)
            }
            completion(photos, nil)
        }
    }
    
    // ServerUser 데이터를 Firestore에 추가하는 함수
    func addUser(user: ServerUser, completion: @escaping (Result<Void, Error>) -> Void) {
        var userData = user
        userData.id = nil  // Firestore에 추가하기 전에 id를 nil로 설정. FireStore 는 문서의 id를 자체적으로 관리한다.
        
        do {
            let documentRef = try db.collection("users").addDocument(from: userData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
            userData.id = documentRef.documentID  // Firestore 문서 ID를 할당
        } catch let error {
            completion(.failure(error))
        }
    }
    
    // ServerConnectionRequest 데이터를 Firestore에 추가하는 함수
    func addConnectionRequest(request: ServerConnectionRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let _ = try db.collection("connectionRequests").document(request.id ?? UUID().uuidString).setData(from: request)
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    // ServerConnection 데이터를 Firestore에 추가하는 함수
    func addConnection(connection: ServerConnection, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let _ = try db.collection("connections").document(connection.id ?? UUID().uuidString).setData(from: connection)
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    // ServerPhoto 데이터를 Firestore에 추가하는 함수
    func addPhoto(photo: ServerPhoto, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let _ = try db.collection("photos").document(photo.id ?? UUID().uuidString).setData(from: photo)
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
}
