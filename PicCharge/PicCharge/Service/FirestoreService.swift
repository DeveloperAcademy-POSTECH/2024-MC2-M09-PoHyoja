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
    func fetchUsers(completion: @escaping ([UserDTO]?, Error?) -> Void) {
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            let users = querySnapshot?.documents.compactMap { document -> UserDTO? in
                try? document.data(as: UserDTO.self)
            }
            completion(users, nil)
        }
    }
    
    // ServerConnectionRequest 데이터를 가져오는 함수
    func fetchConnectionRequests(completion: @escaping ([ConnectionRequestsDTO]?, Error?) -> Void) {
        db.collection("connectionRequests").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            let requests = querySnapshot?.documents.compactMap { document -> ConnectionRequestsDTO? in
                try? document.data(as: ConnectionRequestsDTO.self)
            }
            completion(requests, nil)
        }
    }
    
    // ServerConnection 데이터를 가져오는 함수
    func fetchConnections(completion: @escaping ([ConnectionDTO]?, Error?) -> Void) {
        db.collection("connections").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            let connections = querySnapshot?.documents.compactMap { document -> ConnectionDTO? in
                try? document.data(as: ConnectionDTO.self)
            }
            completion(connections, nil)
        }
    }
    
    // ServerPhoto 데이터를 가져오는 함수
    func fetchPhotos(completion: @escaping ([PhotoDTO]?, Error?) -> Void) {
        db.collection("photos").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            let photos = querySnapshot?.documents.compactMap { document -> PhotoDTO? in
                try? document.data(as: PhotoDTO.self)
            }
            completion(photos, nil)
        }
    }
    
    // ServerUser 데이터를 Firestore에 추가하는 함수
    func addUser(id: String?,
                 role: Role,
                 email: String,
                 uploadCycle: Int?, completion: @escaping (Result<Void, Error>) -> Void) {
        let user = UserDTO(id: id, role: role, email: email, uploadCycle: uploadCycle)
        
        do {
            let _ = try db.collection("users").addDocument(from: user)
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    // ServerConnectionRequest 데이터를 Firestore에 추가하는 함수
    func addConnectionRequest(request: ConnectionRequestsDTO, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let _ = try db.collection("connectionRequests").addDocument(from: request)
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    // ServerConnection 데이터를 Firestore에 추가하는 함수
    func addConnection(connection: ConnectionDTO, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let _ = try db.collection("connections").addDocument(from: connection)
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    // ServerPhoto 데이터를 Firestore에 추가하는 함수
    func addPhoto(photo: PhotoDTO, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let _ = try db.collection("photos").addDocument(from: photo)
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
}
