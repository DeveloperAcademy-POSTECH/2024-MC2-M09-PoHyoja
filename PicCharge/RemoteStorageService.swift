//
//  RemoteStorageService.swift
//  PicCharge
//
//  Created by 남유성 on 12/28/24.
//

import Foundation

/// 원격 스토리지 서비스 프로토콜
protocol RemoteStorageService {
    
    /// 이메일로 유저를 가져옵니다.
    /// - Parameter email: 검색할 유저의 이메일
    /// - Returns: 해당 이메일을 가진 유저 (`User`) 또는 없을 경우 `nil`
    func fetchUserByEmail(_ email: String) async -> User?
    
    /// 이름으로 유저를 가져옵니다.
    /// - Parameter name: 검색할 유저의 이름
    /// - Returns: 해당 이름을 가진 유저 (`User`) 또는 없을 경우 `nil`
    func fetchUserByName(_ name: String) async -> User?
    
    /// 이름으로 유저의 존재 여부를 확인합니다.
    /// - Parameter name: 확인할 유저의 이름
    /// - Returns: 유저가 존재하면 `true`, 없으면 `false`
    /// - Throws: 네트워크 오류 등의 이유로 확인 과정에서 예외 발생 시 예외를 던짐
    func checkUserExists(by name: String) async throws -> Bool
    
    /// 원격 스토리지에 유저 정보를 저장합니다.
    /// - Parameter user: 저장할 유저 정보
    /// - Throws: 저장 과정에서 오류 발생 시 예외를 던짐
    func addUser(_ user: User) async throws
    
    /// 원격 스토리지에서 유저 정보를 삭제합니다.
    /// - Parameter user: 삭제할 유저 정보
    /// - Throws: 삭제 과정에서 오류 발생 시 예외를 던짐
    func deleteUser(_ user: User) async throws
    
    /// 유저 이름을 통해 사진 데이터를 가져옵니다.
    /// - Parameter userName: 사진을 가져올 유저 이름
    /// - Returns: 해당 유저의 사진 목록 (`[Photo]`)
    func fetchPhotos(_ userName: String) async -> [Photo]
    
    /// 유저의 사진을 원격 스토리지에 업로드합니다.
    /// - Parameters:
    ///   - userName: 사진을 업로드할 유저 이름
    ///   - photo: 업로드할 사진 데이터
    /// - Throws: 업로드 과정에서 오류 발생 시 예외를 던짐
    func uploadPhoto(of userName: String, photo: Photo) async throws
    
    /// 원격 스토리지에서 사진을 업데이트합니다.
    /// - Parameter photo: 업데이트할 사진 데이터
    /// - Throws: 업데이트 과정에서 오류 발생 시 예외를 던짐
    func updatePhoto(_ photo: Photo) async throws
    
    /// 원격 스토리지에서 일치하는 ID의 사진을 삭제합니다.
    /// - Parameter photoId: 삭제할 사진의 ID
    /// - Throws: 삭제 과정에서 오류 발생 시 예외를 던짐
    func deletePhoto(of photoId: String) async throws
}
