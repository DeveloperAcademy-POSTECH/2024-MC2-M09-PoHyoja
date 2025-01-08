//
//  LocalStorageService.swift
//  PicCharge
//
//  Created by 남유성 on 12/28/24.
//

import Foundation

/// 로컬 스토리지 서비스 프로토콜
protocol LocalStorageService {
    
    /// 로컬 스토리지에서 현재 유저 정보를 가져옵니다.
    /// - Returns: 현재 유저 정보 (`User`) 또는 없을 경우 `nil`
    func fetchUser() async -> User?
    
    /// 로컬 스토리지에 현재 유저 정보를 저장합니다.
    /// - Parameter user: 저장할 유저 정보
    /// - Throws: 저장 과정에서 오류 발생 시 예외를 던짐
    func addUser(_ user: User) async throws
    
    /// 로컬 스토리지에서 유저 정보를 삭제합니다.
    /// - Parameter name: 삭제할 유저의 이름
    /// - Throws: 삭제 과정에서 오류 발생 시 예외를 던짐
    func deleteUser(_ name: String) async throws
    
    /// 로컬 스토리지에 저장된 모든 사진 데이터를 가져옵니다.
    /// - Returns: 저장된 사진들의 목록 (`[Photo]`)
    func fetchPhotos() async -> [Photo]
    
    /// 로컬 스토리지에 저장된 모든 사진 데이터를 가져옵니다.
    /// - Parameter option: 정렬 기준 파라미터
    /// - Parameter order: 정렬 순서
    /// - Returns: 저장된 사진들의 목록 (`[Photo]`)
    func fetchPhotos(for option: PhotoSortOption, _ order: SortOrder) async -> [Photo]
    
    /// 로컬 스토리지에 사진 1장을 추가합니다.
    /// - Parameter photo: 저장할 사진 데이터
    /// - Throws: 저장 과정에서 오류 발생 시 예외를 던짐
    func addPhoto(_ photo: Photo) async throws
    
    /// 로컬 스토리지에서 일치하는 ID의 사진을 삭제합니다.
    /// - Parameter photoId: 삭제할 사진의 ID
    /// - Throws: 삭제 과정에서 오류 발생 시 예외를 던짐
    func deletePhoto(_ photoId: UUID) async throws
}
