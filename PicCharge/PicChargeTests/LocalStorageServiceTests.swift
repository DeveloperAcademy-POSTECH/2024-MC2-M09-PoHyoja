//
//  LocalStorageServiceTests.swift
//  PicChargeTest
//
//  Created by 남유성 on 12/31/24.
//

import XCTest
@testable import PicCharge

final class LocalStorageServiceTests: XCTestCase {
    
    private var service: LocalStorageService!
    
    override func setUpWithError() throws {
        service = try SwiftDataService(isStoredInMemoryOnly: true)
    }
    
    override func tearDownWithError() throws {
        service = nil
    }
    
    // MARK: - User Tests
    
    func test_신규유저추가후조회() async throws {
        let user = User(name: "에이스", role: .child, email: "ace@ace.com", connectedTo: [])
        try await service.addUser(user)
        
        let fetchedUser = await service.fetchUser()
        
        XCTAssertEqual(fetchedUser?.name, "에이스")
        XCTAssertEqual(fetchedUser?.role, .child)
        XCTAssertEqual(fetchedUser?.email, "ace@ace.com")
    }
    
    func test_유저삭제() async throws {
        let user = User(name: "에이스", role: .child, email: "ace@ace.com", connectedTo: [])
        try await service.addUser(user)
        
        try await service.deleteUser("에이스")
        
        let fetchedUser = await service.fetchUser()
        XCTAssertNil(fetchedUser)
    }
    
    func test_빈DB유저조회() async {
        let fetchedUser = await service.fetchUser()
        XCTAssertNil(fetchedUser)
    }
    
    // MARK: - Photo Tests
    
    func test_사진추가후조회() async throws {
        let photoData1 = Data(count: 1)
        let photoData2 = Data(count: 2)
        
        let photo1 = Photo(id: UUID(), uploadBy: "ace", uploadDate: .now, imgData: photoData1, likeCount: 0, sharedWith: [])
        let photo2 = Photo(id: UUID(), uploadBy: "ace", uploadDate: .now, imgData: photoData2, likeCount: 0, sharedWith: [])
        
        try await service.addPhoto(photo1)
        try await service.addPhoto(photo2)
        
        let photos = await service.fetchPhotos()
        XCTAssertEqual(photos.count, 2)
        XCTAssertEqual(photos[0].uploadBy, "ace")
        XCTAssertEqual(photos[1].uploadBy, "ace")
    }
    
    func test_사진삭제() async throws {
        let photo = Photo(id: UUID(), uploadBy: "ace", uploadDate: .now, imgData: Data(), likeCount: 0, sharedWith: [])
        try await service.addPhoto(photo)
        
        try await service.deletePhoto(photo.id)
        
        let photos = await service.fetchPhotos()
        XCTAssertTrue(photos.isEmpty)
    }
    
    func test_빈DB사진삭제() async {
        let photos = await service.fetchPhotos()
        XCTAssertTrue(photos.isEmpty)
    }
    
    func test_최신순사진정렬() async throws {
        let photoData1 = Data(count: 1)
        let photoData2 = Data(count: 2)
        
        let photo1 = Photo(id: UUID(), uploadBy: "ace1", uploadDate: .now, imgData: photoData1, likeCount: 0, sharedWith: [])
        let photo2 = Photo(id: UUID(), uploadBy: "ace2", uploadDate: .now.addingTimeInterval(-3600), imgData: photoData2, likeCount: 0, sharedWith: [])
        
        try await service.addPhoto(photo1)
        try await service.addPhoto(photo2)
        
        let photos = await service.fetchPhotos()
        XCTAssertEqual(photos.count, 2)
        XCTAssertEqual(photos[0].uploadBy, "ace1") // 최신 사진
        XCTAssertEqual(photos[1].uploadBy, "ace2") // 오래된 사진
    }
    
    func test_오래된순사진정렬() async throws {
        let photoData1 = Data(count: 1)
        let photoData2 = Data(count: 2)
        
        let photo1 = Photo(id: UUID(), uploadBy: "ace1", uploadDate: .now, imgData: photoData1, likeCount: 0, sharedWith: [])
        let photo2 = Photo(id: UUID(), uploadBy: "ace2", uploadDate: .now.addingTimeInterval(-3600), imgData: photoData2, likeCount: 0, sharedWith: [])
        
        try await service.addPhoto(photo1)
        try await service.addPhoto(photo2)
        
        let photos = await service.fetchPhotos(for: .uploadDate, .forward)
        XCTAssertEqual(photos.count, 2)
        XCTAssertEqual(photos[0].uploadBy, "ace2") // 오래된 사진
        XCTAssertEqual(photos[1].uploadBy, "ace1") // 최신 사진
    }
    
}
