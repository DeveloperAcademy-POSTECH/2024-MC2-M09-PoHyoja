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
    
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    private var documentListener: ListenerRegistration?
    
    private init(){}
    
    /// 이메일로 Firestore에서 유저 정보 가져오기
    func fetchUserByEmail(email: String) async -> User? {
        do {
            let snapshot = try await db.collection("users")
                .whereField("email", isEqualTo: email)
                .getDocuments()
            
            print("서버에서 \(email) 유저 정보를 찾는다.")
            
            guard let document = snapshot.documents.first else {
                return nil
            }
            
            return try document.data(as: User.self)
        } catch {
            print("유저 데이터 페치 에러: \(error)")
            return nil
        }
    }
    
    /// 이름으로 Firestore에서 유저 정보 가져오기
    func fetchUserByName(name: String) async -> User? {
        do {
            let snapshot = try await db.collection("users")
                .whereField("name", isEqualTo: name)
                .getDocuments()
            
            print("서버에서 \(name) 유저 정보를 찾는다.")
            
            guard let document = snapshot.documents.first else {
                return nil
            }
            
            return try document.data(as: User.self)
        } catch {
            print("유저 데이터 페치 에러: \(error)")
            return nil
        }
    }
    
    /// 서버에 유저 추가
    func addUser(user: User) async throws {
        guard let userId = user.id else {
            throw FirestoreServiceError.invalidUserId
        }
        
        if try await checkUserExists(userName: user.name) {
            throw FirestoreServiceError.userAlreadyExists
        }
        
        do {
            try db.collection("users").document(userId).setData(from: user)
            print("서버에 유저 추가됨 id: \(userId), data: \(user)")
        } catch {
            throw error
        }
    }
    
    /// 서버에 유저가 존재하는지 이름으로 확인
    func checkUserExists(userName: String) async throws -> Bool {
        guard !userName.isEmpty else {
            throw FirestoreServiceError.invalidUserId
        }
        
        let querySnapshot = try await db.collection("users")
            .whereField("name", isEqualTo: userName)
            .getDocuments()
        
        return !querySnapshot.documents.isEmpty
    }
    
    /// 서버에서 유저 살제
    func deleteUser(user: User) async throws {
        guard let userId = user.id else {
            throw FirestoreServiceError.invalidUserId
        }
        try await db.collection("users").document(userId).delete()
    }
    
    /// 연결 요청을 Firestore에 추가
    func addConnectRequests(currentUserName: String, otherUserName: String) async throws {
        let connectionRequest = ConnectionRequestsDTO(
            id: nil,
            from: currentUserName,
            to: otherUserName,
            status: .pending,
            requestDate: Date()
        )
        
        // Upload connection request
        try db.collection("connectionRequests").addDocument(from: connectionRequest)
    }
    
    
    /// 본인이 한 연결 요청을 Firestore에서 가져오는 메서드
    func fetchConnectionRequests(userName: String) async throws -> [ConnectionRequestsDTO] {
        let snapshot = try await db.collection("connectionRequests")
            .whereField("from", isEqualTo: userName)
            .whereField("status", isEqualTo: "pending")
            .getDocuments()
        
        print("페치된 문서: \(snapshot.documents)") // 디버깅을 위해 출력
        
        return snapshot.documents.compactMap { document in
            do {
                return try document.data(as: ConnectionRequestsDTO.self)
            } catch {
                print("문서 디코딩 실패: \(document.data()), error: \(error)")
                return nil
            }
        }
    }
    
    func listenRequest(from userName: String, completion: @escaping (Result<[ConnectionRequestsDTO], FirestoreServiceError>) -> Void) {
        removeListener()
        
        documentListener = db.collection("connectionRequests")
            .whereField("from", isEqualTo: userName)
            // 1. status -> pending은 삭제가 된다
            .whereField("status", in: ["pending", "rejected", "accepted"])
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("문서 찾을 수 없음: \(error!)")
                    completion(.failure(FirestoreServiceError.documentNotFound))
                    return
                }
                
                var connections: [ConnectionRequestsDTO] = []
                
                document.documentChanges.forEach { change in
                    switch change.type {
                    case .added:
                        print("added")
                        do {
                            let connection = try change.document.data(as: ConnectionRequestsDTO.self)
                            guard connection.status == .pending else { return }
                            connections.append(connection)
                            print(connection.status)
                            
                        } catch {
                            print("문서 디코딩 실패: \(change.document.data()), error: \(error)")
                            completion(.failure(.decodingError))
                        }
                    case .modified:
                        print("modified")
                        do {
                            let connection = try change.document.data(as: ConnectionRequestsDTO.self)
                            guard connection.status == .accepted || connection.status == .rejected else { return }
                            connections.append(connection)
                            print(connection.status)
                            
                        } catch {
                            print("문서 디코딩 실패: \(change.document.data()), error: \(error)")
                            completion(.failure(.decodingError))
                        }
                    default:
                        break
                    }
                    completion(.success(connections))
                }
            }
    }

    func listenRequest(to userName: String, completion: @escaping (Result<[ConnectionRequestsDTO], FirestoreServiceError>) -> Void) {
        removeListener()
        
        documentListener = db.collection("connectionRequests")
            .whereField("to", isEqualTo: userName)
            .whereField("status", isEqualTo: "pending")
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("문서 찾을 수 없음: \(error!)")
                    completion(.failure(FirestoreServiceError.documentNotFound))
                    return
                }
                
                var connections: [ConnectionRequestsDTO] = []
                
                document.documentChanges.forEach { change in
                    switch change.type {
                    case .added:
                        do {
                            let connection = try change.document.data(as: ConnectionRequestsDTO.self)
                            connections.append(connection)
                        } catch {
                            print("문서 디코딩 실패: \(change.document.data()), error: \(error)")
                            completion(.failure(.decodingError))
                        }
                    default:
                        break
                    }
                    completion(.success(connections))
                }
            }
    }
    
    func removeListener() {
        documentListener?.remove()
    }
    
    /// 연결 요청을 넘겨준 ConnectionRequestsDTO 로 업데이트하는 메서드
    func updateConnectionRequest(request: ConnectionRequestsDTO) async throws {
        guard let requestId = request.id else {
            throw FirestoreServiceError.invalidRequestId
        }
        
        try db.collection("connectionRequests").document(requestId).setData(from: request)
    }
    
    /// 사용자 연결 정보를 넘겨준 User 로 업데이트하는 메서드
    func updateUserConnections(user: User) async throws {
        guard let userId = user.id else {
            throw FirestoreServiceError.invalidUserId
        }
        
        try db.collection("users").document(userId).setData(from: user, merge: true)
    }
}
