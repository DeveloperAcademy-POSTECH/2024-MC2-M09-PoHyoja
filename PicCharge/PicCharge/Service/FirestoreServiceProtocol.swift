//
//  FirestoreServiceProtocol.swift
//  PicCharge
//
//  Created by 남유성 on 5/18/24.
//

import Foundation
import PhotosUI

protocol FirestoreServiceProtocol {
    /// 사진 리스트 조회: 유저 정보를 기준으로 업로드된 사진을 불러옵니다.
    /// 
    /// - Parameter user: 사용자 본인. (사용자의 역할 무관)
    /// - Returns: 불러온 사진 반환, 한장도 없거나 실패 시 nil
    func fetchPhotos(user: User) async throws -> [Photo]?

    /// 사진 추가: 자식 유저 정보를 기준으로 DB에 사진을 업로드합니다.
    ///
    /// - Parameters:
    ///   - child: 사용자 본인 (자식)
    ///   - parent: 사용자와 연결된 부모 유저
    ///   - photo: 업로드 할 사진.
    ///   photo 에는 올바른 id, uploadBy, uploadDate, urlString, likeCount 가 모두 저장되어 있어야 한다.
    func addPhoto(child: User, parent: User, imageData: Data) async throws

    /// 사진 변경(좋아요 수 추가): 사진 정보를 기준으로 DB의 좋아요를 변경합니다.
    /// - Parameters:
    ///   - user: 유저 본인 (부모)
    ///   - photo: 좋아요 수 변경할 사진
    ///   - plusLikeCount: 추가할 좋아요 개수
    func updatePhotoLikeCount(user: User, of photo: Photo, by plusLikeCount: Int) async throws
    
    
    /// 사진 삭제: 사진 정보를 기준으로 DB에서 사진을 삭제합니다.
    func deletePhoto(photo: Photo) async throws
    
    /// 유저 조회: (자식/부모)사용자의 역할을 기준으로 DB에서 반대 역할인 유저의 정보를 불러옵니다. 입력된 아이디를 포함하는 모든 계정 정보를 리턴합니다.
    /// 사용자 본인의 반대 역할이고, 아이디가 searchId로 시작하는 아이디를 모두 찾아서 반환합니다. 찾지 못할경우 userNotFound 예외를 발생합니다.
    func fetchSerchedUsers(searchUserId: String) async throws -> [User]
    
    /// 유저 추가: (자식/부모)유저 정보를 기준으로 DB에 유저를 추가합니다.   아이디가 중복일 경우 다시 회원가입 해야 합니다.
    /// - Parameters:
    ///   - user: 유저의 정보 (이메일과 아이디는 정확한 정보가 담겨있어야 한다.
    ///
    /// 사용 예시:
    /// ```swift
    /// Task {
    ///     do {
    ///         try await firestoreService.addUser(user: user)
    ///         print("사용자가 성공적으로 추가되었습니다.")
    ///     } catch {
    ///         print("사용자 추가 실패: \(error.localizedDescription)")
    ///     }
    /// }
    /// ```
    func addUser(user: User) async throws
    
    /// 유저 탈퇴: (자식/부모)유저 정보를 기준으로 DB에서 유저를 삭제합니다. 연결된 유저가 있다면 남은 유저의 연결여부를 리셋합니다.
    ///
    /// 뷰 계층에서의 함수 호출 예시
    /// ```
    ///    func deleteUserExample(user: any User) {
    ///        Task {
    ///            do {
    ///                try await firestoreService.deleteUser(user: user)
    ///                print("사용자가 성공적으로 삭제되었습니다.")
    ///            } catch FirestoreServiceError.invalidUserId {
    ///                print("유효하지 않은 사용자 ID입니다.")
    ///            } catch {
    ///                print("사용자 삭제 실패: \(error.localizedDescription)")
    ///            }
    ///        }
    ///    }
    /// ```
    func deleteUser(user: User) async throws
    
    /// 유저 수정(연결): 자식과 부모 유저 정보를 기준으로 DB에서 유저를 서로 연결 처리 합니다.
    func connectUser(of userA: User, with userB: User) async throws
    
    /// 유저 연결 상태 요청: (자식/부모)유저 정보를 기준으로 현재 연결 상태를 리턴합니다.
    func fetchConnectionStatus(user: User) async throws -> ConnectionRequestStatus
}
