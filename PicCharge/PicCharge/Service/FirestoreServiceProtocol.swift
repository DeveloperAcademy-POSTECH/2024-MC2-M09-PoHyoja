//
//  FirestoreServiceProtocol.swift
//  PicCharge
//
//  Created by 남유성 on 5/18/24.
//

import Foundation

protocol FireStoreServiceProtocol {
    // 사진 리스트 조회: 자식 유저 정보를 기준으로 업로드된 사진을 불러옵니다.
    func fetchPhotos(user: User, completion: @escaping ([Photo]?, Error?) -> Void)
    // 사진 추가: 자식 유저 정보를 기준으로 DB에 사진을 업로드합니다.
    func addPhoto(user: User, photo: Photo, completion: @escaping (Result<Void, Error>) -> Void)
    // 사진 변경(좋아요 수 추가): 사진 정보를 기준으로 DB의 좋아요를 변경합니다.
    func updatePhotoLikeCount(photo: Photo, completion: @escaping (Result<Void, Error>) -> Void)
    // 사진 삭제: 사진 정보를 기준으로 DB에서 사진을 삭제합니다.
    func deletePhoto(photo: Photo, completion: @escaping (Result<Void, Error>) -> Void)
    
    // 유저 조회: (자식/부모)유저 아이디를 기준으로 DB에서 유저 정보를 불러옵니다. 입력된 아이디를 포함하는 모든 계정 정보를 리턴합니다.
    func fetchUsers(userId: String, completion: @escaping (User?, Error?) -> Void)
    // 유저 추가: (자식/부모)유저 정보를 기준으로 DB에 유저를 추가합니다.
    func addUser(user: User, completion: @escaping (Result<Void, Error>) -> Void)
    // 유저 탈퇴: (자식/부모)유저 정보를 기준으로 DB에서 유저를 삭제합니다. 연결된 유저가 있다면 남은 유저의 연결여부를 리셋합니다.
    func deleteUser(user: User, completion: @escaping (Result<Void, Error>) -> Void)
    // 유저 수정(연결): 자식과 부모 유저 정보를 기준으로 DB에서 유저를 서로 연결 처리 합니다.
    func connectUser(of userA: User, with userB: User, completion: @escaping (Result<Void, Error>) -> Void)
    
    // 유저 연결 상태 요청: (자식/부모)유저 정보를 기준으로 현재 연결 상태를 리턴합니다.
    func fetchConnectionStatus(user: User, completion: @escaping (ConnectionRequestStatus?, Error?) -> Void)
}
