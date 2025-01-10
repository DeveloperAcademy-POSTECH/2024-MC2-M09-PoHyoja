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
    
    func deletePhoto(photo: Photo) {
        guard let idx = photos.firstIndex(where: { $0.id == photo.id }) else {
            return
        }
            
        // UI 처리
        photos.remove(at: idx)
        
        Task.detached { [weak self] in
            guard let ss = self else { return }
            
            do {
                // 1. 원격 우선 삭제
                try await ss.remoteStorageService.deletePhoto(of: photo.id)
                
                // 2. 로컬 삭제
                try await ss.localStorageService.deletePhoto(photo.id)
                
            } catch {
                // 에러 시 복구
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    
                    self.photos.insert(photo, at: idx)
                }
            }
        }
    }
}
