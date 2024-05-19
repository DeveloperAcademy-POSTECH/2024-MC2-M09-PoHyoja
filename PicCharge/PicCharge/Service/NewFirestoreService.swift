//
//  NewFirestoreService.swift
//  PicCharge
//
//  Created by 이상현 on 5/19/24.
//
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class NewFirestoreService: FirestoreServiceProtocol {
    
    private let db = Firestore.firestore()

    /// 사진 리스트 조회: 자식 유저 정보를 기준으로 업로드된 사진을 불러옵니다.
    func fetchPhotos(user: any User) async throws -> [Photo]? {
        <#code#>
    }
    
    /// 사진 추가: 자식 유저 정보를 기준으로 DB에 사진을 업로드합니다.
    func addPhoto(user: any User, photo: Photo) async throws {
        
    }
    
    /// 사진 변경(좋아요 수 추가): 사진 정보를 기준으로 DB의 좋아요를 변경합니다.
    func updatePhotoLikeCount(photo: Photo) async throws {
        <#code#>
    }
    
    /// 사진 삭제: 사진 정보를 기준으로 DB에서 사진을 삭제합니다.
    func deletePhoto(photo: Photo) async throws {
        let photoId = photo.id
        try await db.collection("photos").document(photoId.uuidString).delete()
        // TODO: 사진이 공유된 사람들만 삭제 가능
    }
    
    /// 유저 조회: (자식/부모)사용자의 역할을 기준으로 DB에서 반대 역할인 유저의 정보를 불러옵니다. 입력된 아이디를 포함하는 모든 계정 정보를 리턴합니다.
    ///
    /// 사용자 본인의 반대 역할이고, 아이디가 searchId로 시작하는 아이디를 모두 찾아서 반환합니다. 찾지 못할경우 userNotFound 예외를 발생합니다.
    func fetchUsers(searchId: String) async throws -> [User] {
        let document = try await db.collection("users")
            .whereField("role", isEqualTo: Role.child.rawValue) // TODO: Rold.child 대신 유저의 역할 가져와서 반대 역할 검색해야 함
            .start(at: [searchId])
            .end(at: [searchId + "\u{f8ff}"])
            .getDocuments()
        
        guard !document.isEmpty else {
            throw FirestoreServiceError.userNotFound
        }
        
        let users = document.documents.compactMap { document -> (any User)? in
            guard let userDTO = try? document.data(as: UserDTO.self) else {
                return nil
            }
            switch userDTO.role {
            case .parent:
                return Parent(from: userDTO)
            case .child:
                return Child(from: userDTO)
            case .none:
                return nil
            }
        }
        
        return users
    }
    
    /// 유저 추가: (자식/부모)유저 정보를 기준으로 DB에 유저를 추가합니다.
    /// User 는 email 과 role 은 정확한 데이터가 담겨있어야 합니다.
    // 사용 예시:
    // Task {
    //     do {
    //         try await firestoreService.addUser(user: user)
    //         print("사용자가 성공적으로 추가되었습니다.")
    //     } catch {
    //         print("사용자 추가 실패: \(error.localizedDescription)")
    //     }
    // }
    func addUser(user: any User) async throws {
        let userDTO = UserDTO(user: user)
        try db.collection("users").addDocument(from: userDTO)
    }
    
    /// 유저 탈퇴: (자식/부모)유저 정보를 기준으로 DB에서 유저를 삭제합니다. 연결된 유저가 있다면 남은 유저의 연결여부를 리셋합니다.
    //
    // 뷰 계층에서의 함수 호출 예시
    //    func deleteUserExample(user: any User) {
    //        Task {
    //            do {
    //                try await firestoreService.deleteUser(user: user)
    //                print("사용자가 성공적으로 삭제되었습니다.")
    //            } catch FirestoreServiceError.invalidUserId {
    //                print("유효하지 않은 사용자 ID입니다.")
    //            } catch {
    //                print("사용자 삭제 실패: \(error.localizedDescription)")
    //            }
    //        }
    //    }
    func deleteUser(user: any User) async throws {
        guard let userId = user.id else {
            throw FirestoreServiceError.invalidUserId
        }
        try await db.collection("users").document(userId).delete()
    }
    
    /// 유저 수정(연결): 자식과 부모 유저 정보를 기준으로 DB에서 유저를 서로 연결 처리 합니다.
    func connectUser(of userA: any User, with userB: any User) async throws {
        <#code#>
    }
    
    /// 유저 연결 상태 요청: (자식/부모)유저 정보를 기준으로 현재 연결 상태를 리턴합니다.
    func fetchConnectionStatus(user: any User) async throws -> ConnectionRequestStatus {
        <#code#>
    }
}
