//
//  PhotoViewModel.swift
//  PicCharge
//
//  Created by 남유성 on 12/28/24.
//

import SwiftUI

@Observable
final class PhotoViewModel {
    private(set) var photos: [Photo] = Photo.mocks
    
    @ObservationIgnored
    private let localStorageService: LocalStorageService
    
    @ObservationIgnored
    private let remoteStorageService: RemoteStorageService
    
    init(
        localStorageService: LocalStorageService,
        remoteStorageService: RemoteStorageService
    ) {
        self.localStorageService = localStorageService
        self.remoteStorageService = remoteStorageService
    }
}

extension PhotoViewModel {
    func uploadPhoto(of user: User, imgData: Data) async throws {
        
        let photo = Photo(of: user, imgData: imgData)
        
        // 1. 원격 사진 데이터 업로드
        let urlString = try await remoteStorageService.uploadPhotoData(of: user.name, photo: photo)
        
        do {
            // 2. 원격 사진 정보 저장
            try await remoteStorageService.addPhoto(photo, urlString: urlString)
            
            // 3. UI에 최신순 데이터 추가
            await MainActor.run { photos.insert(photo, at: 0) }
            
        } catch {
            
            // 2-1. 원격 사진 정보 저장 실패 시 - 업로드한 Data 삭제
            try await remoteStorageService.deletePhotoData(of: urlString)
            
            throw error
        }
        
        do {
            // 4. 로컬 저장
            try await localStorageService.addPhoto(photo)
            
        } catch {
            // 로컬 저장 에러는 무시
            // (SOT - 원격) : 원격 성공, 로컬 실패 시에는 UI 복구 -> sync에서 해결!
        }
    }
    
    func syncPhoto(of userName: String) async {
        do {
            let remoteData = try await remoteStorageService.fetchPhotos(userName)
            let localData = await localStorageService.fetchPhotos()
            
            // 3. 원격 데이터를 기준으로 로컬 데이터 업데이트
            let remoteSet = Set(remoteData)
            let localSet = Set(localData)
            
            // (1) 업데이트할 항목: 동일한 ID를 가진 항목 중 데이터가 다른 항목
            let photosToUpdate = Array(localSet.intersection(remoteSet))
                .filter { localItem in
                    guard let remoteItem = remoteSet.first(where: { $0.id == localItem.id }) else { return false }
                    
                    return localItem.likeCount != remoteItem.likeCount
                }
            
            try await localStorageService.updatePhotos(photosToUpdate)
            
            // (2) 추가할 항목: 원격에만 있는 데이터
            var photosToAdd = Array(remoteSet.subtracting(localSet))
            
            for i in 0..<photosToAdd.count {
                guard let urlString = photosToAdd[i].urlString else { continue }
                
                photosToAdd[i].imgData = try await remoteStorageService.downloadPhotoData(of: urlString)
            }
            
            try await localStorageService.addPhotos(photosToAdd)
            
            // (3) 삭제할 항목: 로컬에만 있는 데이터
            let photosToDelete = Array(localSet.subtracting(remoteSet))
            try await localStorageService.deletePhotos(photosToDelete.map { $0.id })
            
            print("총\(remoteData.count) 개의 이미지")
            print("\(photosToUpdate.count + photosToAdd.count + photosToDelete.count) 개의 이미지 동기화함")
            print("\(photosToUpdate.count) 개의 사진 업데이트됨")
            print("\(photosToAdd.count) 개의 사진 추가됨")
            print("\(photosToDelete.count) 개의 사진 삭제됨")
            
            photos = await localStorageService.fetchPhotos()
        } catch {
            print("사진 데이터 동기화 실패: \(error)")
        }
    }
    
    /// 해당 사진을 삭제합니다.
    ///
    /// 1. photos에서 우선 사진을 삭제해 UI에 반영합니다.
    /// 2. 비동기적으로 원격 / 로컬에서 사진을 삭제합니다.
    /// 3. 에러 발생 시 삭제한 UI를 복구합니다.
    ///
    /// - Parameter photo: 삭제할 photo
    func deletePhoto(_ photo: Photo) async throws {
        
        guard let idx = photos.firstIndex(where: { $0.id == photo.id }) else { return }
        
        // 1. UI에서 Photo 제거
        await MainActor.run { _ = photos.remove(at: idx) }
        
        do {
            // 2-1. 원격 우선 삭제
            try await remoteStorageService.deletePhoto(of: photo.id)
            
            // 2-2. 로컬 삭제
            // (SOT - 원격) : 원격 성공, 로컬 실패 시에는 UI 복구 -> sync에서 해결!
            try await localStorageService.deletePhoto(photo.id)
            
        } catch {
            
            // 3. UI에서 Photo 복구
            await MainActor.run { photos.insert(photo, at: idx) }
            throw error
        }
    }
    
    func deleteAllLocal() async throws {
        try await localStorageService.deleteAllPhotos()
    }
}
