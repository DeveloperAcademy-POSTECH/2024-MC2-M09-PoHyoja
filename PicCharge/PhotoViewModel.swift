//
//  PhotoViewModel.swift
//  PicCharge
//
//  Created by 남유성 on 12/28/24.
//

import SwiftUI

@Observable
final class PhotoViewModel {
    private(set) var photos: [Photo] = []
    
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
    
    func downloadPhoto(of urlString: String) async throws -> Data {
        try await remoteStorageService.downloadPhotoData(of: urlString)
    }
    
    func savePhotoAtLocal(photo: Photo) async throws {
        try await localStorageService.updatePhoto(photo)
    }
    
    func syncPhoto(of userName: String?) async {
        guard let userName else { return }
        
        do {
            // 원격 및 로컬 데이터 가져오기
            async let remoteData = remoteStorageService.fetchPhotos(userName)
            async let localData = localStorageService.fetchPhotos()
                    
            let remotePhotos = try await remoteData
            let localPhotos = await localData
            
            // remoteSet과 localSet을 ID 기반 딕셔너리로 변환
            let remoteMap = Dictionary(uniqueKeysWithValues: remotePhotos.map { ($0.id, $0) })
            let localMap = Dictionary(uniqueKeysWithValues: localPhotos.map { ($0.id, $0) })
            
            // (1) 업데이트할 항목: 동일한 ID를 가진 항목 중 reaction이 다른 항목
            let photosToUpdate = localMap.filter { remoteMap[$0]?.reaction != $1.reaction }.map { $0.value }
            
            // (2) 추가할 항목: remoteMap에만 존재하는 항목
            let photosToAdd = remoteMap.filter { !localMap.keys.contains($0.key) }.map { $0.value }
                    
            // (3) 삭제할 항목: localMap에만 존재하는 항목
            let photoIdsToDelete = localMap.filter { !remoteMap.keys.contains($0.key) }.map { $0.key }
            
            // 동일 Context 직렬 처리
            try await localStorageService.updatePhotos(photosToUpdate)
            try await localStorageService.addPhotos(photosToAdd)
            try await localStorageService.deletePhotos(photoIdsToDelete)
            
            print("총 \(remotePhotos.count) 개의 이미지")
            print("\(photosToUpdate.count + photosToAdd.count + photoIdsToDelete.count) 개의 이미지 동기화함")
            print("\(photosToUpdate.count) 개의 사진 업데이트됨")
            print("\(photosToAdd.count) 개의 사진 추가됨")
            print("\(photoIdsToDelete.count) 개의 사진 삭제됨")
            
            // 최종적으로 로컬 데이터를 가져와 UI 업데이트
            let photos = await localStorageService.fetchPhotos()
            
            await MainActor.run {
                self.photos = photos
            }
            
        } catch {
            await GlobalAlert.shared.show(message: "동기화 실패")
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
