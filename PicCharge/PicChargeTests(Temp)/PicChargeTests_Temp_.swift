//
//  PicChargeTests_Temp_.swift
//  PicChargeTests(Temp)
//
//  Created by 남유성 on 1/1/25.
//

import XCTest
@testable import PicCharge_Dev
import FirebaseStorage
import FirebaseFirestore

class TestFireStoreRepository: FireStoreRepository {
    override var userCollection: String { "testUsers" }
    override var photoCollection: String { "testPhotos" }
    override var folder: String { "testPhotos" }
    
    private let testFireStore: Firestore
    
    override init(fireStore: Firestore, storage: Storage) {
        self.testFireStore = fireStore
        super.init(fireStore: fireStore, storage: storage)
    }
    
    func clearTests() async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for collection in [userCollection, photoCollection] {
                group.addTask {
                    try await self.clearCollection(named: collection)
                }
            }
        
            try await group.waitForAll()
        }
    }
    
    private func clearCollection(named collectionName: String) async throws {
        let documents = try await testFireStore
            .collection(collectionName)
            .getDocuments()
            .documents
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for document in documents {
                group.addTask {
                    try await document.reference.delete()
                }
            }
            try await group.waitForAll()
        }
    }
}

final class FireStoreRepositoryTest: XCTestCase {
    
    var service: RemoteStorageService!
    
    var unknownUser: User!
    var myUser: User!
    var newUser: User!
    var userForDelete: User!
    
    var samplePhoto: Photo!
    var invalidPhoto: Photo!
    
    override func setUpWithError() throws {
        service = TestFireStoreRepository(
            fireStore: .firestore(),
            storage: .storage()
        )
        
        unknownUser = User(
            name: "unknown",
            role: .child,
            email: "user@unknown.com",
            connectedTo: []
        )
        myUser = User(
            name: "myUser",
            role: .child,
            email: "user@my.com",
            connectedTo: []
        )
        newUser = User(
            name: "otherUser",
            role: .child,
            email: "user@other.com",
            connectedTo: []
        )
        userForDelete = User(
            name: "userForDelete",
            role: .child,
            email: "user@delete.com",
            connectedTo: []
        )
        samplePhoto = Photo(
            id: UUID(),
            uploadBy: "myUser",
            uploadDate: .now,
            imgData: Data("sample image".utf8),
            likeCount: 0,
            sharedWith: ["myUser"]
        )
        invalidPhoto = Photo(
            id: UUID(),
            uploadBy: "",
            uploadDate: .now,
            imgData: Data("invalid image".utf8),
            likeCount: 0,
            sharedWith: []
        )
    }
    
    override func tearDownWithError() throws {
        let expectation = self.expectation(description: "Delete Test Data")
        Task {
            do {
                try await (service as? TestFireStoreRepository)?.clearTests()
                expectation.fulfill()
                clear()
            } catch {
                XCTFail("Failed to create test data: \(error)")
                clear()
            }
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func clear() {
        service = nil
        unknownUser = nil
        myUser = nil
        newUser = nil
        userForDelete = nil
        samplePhoto = nil
    }
    
    func test_() {
        guard let service = service as? TestFireStoreRepository
        else {
            XCTFail("테스트할 수 없는 레포지토리입니다.")
            return
        }
        
        XCTAssertEqual(service.userCollection, "testUsers")
        XCTAssertEqual(service.photoCollection, "testPhotos")
        XCTAssertEqual(service.folder, "testPhotos")
    }
    
    func test_유저_이메일로_조회_없는_유저() async throws {
        let fetchUser = try await service.fetchUserByEmail(unknownUser.email)
        
        XCTAssertNil(fetchUser) // nil
    }
    
    func test_유저_이메일로_조회_있는_유저() async throws {
        do {
            try await service.addUser(myUser)
        } catch {
            XCTFail("테스트할 유저가 추가에 실패했습니다.")
        }
        
        do {
            let fetchUser = try await service.fetchUserByEmail(myUser.email)
            
            XCTAssertNotNil(fetchUser)
            XCTAssertEqual(fetchUser?.name, myUser.name)
            XCTAssertEqual(fetchUser?.email, myUser.email)
        } catch {
            XCTFail("유저 이메일로 조회 테스트에 실패했습니다.")
        }
    }
    
    func test_없는유저_이름으로_조회() async throws {
        do {
            let fetchUser = try await service.fetchUserByName(unknownUser.name)
            
            XCTAssertNil(fetchUser) // nil
        } catch {
            XCTFail("유저 이름으로 조회 테스트에 실패했습니다.")
        }
    }
    
    func test_유저_이름으로_조회_있는_유저() async throws {
        do {
            try await service.addUser(myUser)
        } catch {
            XCTFail("테스트할 유저가 추가에 실패했습니다.")
        }
        
        do {
            let fetchUser = try await service.fetchUserByName(myUser.name)
            
            XCTAssertNotNil(fetchUser)
            XCTAssertEqual(fetchUser?.name, myUser.name)
            XCTAssertEqual(fetchUser?.email, myUser.email)
        } catch {
            XCTFail("유저 이름으로 조회 테스트에 실패했습니다.")
        }
    }
    
    func test_유저_존재여부_확인() async throws {
        do {
            try await service.addUser(myUser)
        } catch {
            XCTFail("테스트할 유저가 추가에 실패했습니다.")
        }
        
        let isUnknownExist = try await service.checkUserExists(by: unknownUser.name)
        let isMyUserExist = try await service.checkUserExists(by: myUser.name)
        
        XCTAssertFalse(isUnknownExist)
        XCTAssertTrue(isMyUserExist)
    }
    
    func test_신규_유저_추가() async throws {
        do {
            try await service.addUser(newUser)
        } catch {
            XCTFail("테스트할 유저가 추가에 실패했습니다.")
        }
        
        do {
            let fetchUser = try await service.fetchUserByName(newUser.name)
            
            XCTAssertNotNil(fetchUser)
            XCTAssertEqual(fetchUser?.name, newUser.name)
        } catch {
            XCTFail("신규 유저 추가 테스트에 실패했습니다.")
        }
    }
    
    func test_신규_유저_추가_중복() async throws {
        do {
            try await service.addUser(newUser)
        } catch {
            XCTFail("테스트할 유저가 추가에 실패했습니다.")
        }
        
        do {
            try await service.addUser(newUser)
            XCTFail("중복으로 유저를 추가가 가능해 테스트에 실패했습니다.")
        } catch let error as FireStoreError {
            XCTAssertEqual(error, .userAlreadyExists)
        } catch {
            XCTFail("알수 없는 오류로 테스트에 실패했습니다.")
        }
    }
    
    func test_기존유저_삭제() async throws {
        do {
            try await service.addUser(userForDelete)
        } catch {
            XCTFail("테스트할 유저가 추가에 실패했습니다.")
        }
        
        do {
            try await service.deleteUser(userForDelete)
        } catch {
            XCTFail("유저 삭제에 실패했습니다.")
        }
        
        do {
            let fetchUser = try await service.fetchUserByName(userForDelete.name)
            
            XCTAssertNil(fetchUser)
        } catch {
            XCTFail("테스트할 유저가 조회에 실패했습니다.")
        }
    }
    
    // MARK: - Photo
    
    func test_사진_업로드_데이터_조회() async throws {
        guard let imgData = samplePhoto.imgData else {
            XCTFail("테스트할 사진 데이터가 빈 데이터입니다.")
            return
        }
        
        guard let urlString = try? await service.uploadPhotoData(of: myUser.name, photo: samplePhoto, imgData: imgData)
        else {
            XCTFail("테스트에 사용될 사진 업로드에 실패했습니다.")
            return
        }
        
        do {
            try await service.addPhoto(samplePhoto, urlString: urlString)
        } catch {
            XCTFail("테스트에 사용될 사진 추가에 실패했습니다.")
            return
        }
        
        do {
            let photos = try await service.fetchPhotos(myUser.name)
            
            XCTAssertNotNil(photos)
            XCTAssertTrue(photos.contains { $0.id == samplePhoto.id })
        } catch {
            
            XCTFail("사진 조회 테스트에 실패 했습니다.")
        }
    }
    
    func test_사진_조회_Empty_이름() async {
        do {
            _ = try await service.fetchPhotos("")
            XCTFail("예상한 에러가 발생하지 않았습니다.")
            
        } catch let error as FireStoreError {
            XCTAssertEqual(error, .invalidUserName)
        } catch {
            XCTFail("예상한 에러와 다른 에러가 발생했습니다.")
        }
    }
    
    func test_사진_다운로드() async throws {
        guard let imgData = samplePhoto.imgData else {
            XCTFail("테스트할 사진 데이터가 빈 데이터입니다.")
            return
        }
        
        guard let urlString = try? await service.uploadPhotoData(of: myUser.name, photo: samplePhoto, imgData: imgData)
        else {
            XCTFail("테스트에 사용될 사진 업로드에 실패했습니다.")
            return
        }
        
        do {
            let photoData = try await service.downloadPhotoData(of: urlString)
            
            XCTAssertNotNil(photoData)
            XCTAssertEqual(photoData, imgData)
        } catch {
            XCTFail("사진 다운로드에 실패했습니다.")
        }
    }
    
    func test_사진_업데이트() async throws {
        guard let imgData = samplePhoto.imgData else {
            XCTFail("테스트할 사진 데이터가 빈 데이터입니다.")
            return
        }
        
        guard let urlString = try? await service.uploadPhotoData(of: myUser.name, photo: samplePhoto, imgData: imgData)
        else {
            XCTFail("테스트에 사용될 사진 업로드에 실패했습니다.")
            return
        }
        
        do {
            try await service.addPhoto(samplePhoto, urlString: urlString)
        } catch {
            XCTFail("테스트에 사용될 사진 추가에 실패했습니다.")
            return
        }
        
        do {
            samplePhoto.likeCount = 1
            try await service.updatePhoto(samplePhoto)
        }
        
        let storedPhotos = try await service.fetchPhotos(myUser.name)
        XCTAssertEqual(storedPhotos.filter { $0.id == samplePhoto.id }.first?.likeCount, 1)
    }
    
    func test_사진_삭제() async throws {
        guard let imgData = samplePhoto.imgData else {
            XCTFail("테스트할 사진 데이터가 빈 데이터입니다.")
            return
        }
        
        guard let urlString = try? await service.uploadPhotoData(of: myUser.name, photo: samplePhoto, imgData: imgData)
        else {
            XCTFail("테스트에 사용될 사진 업로드에 실패했습니다.")
            return
        }
        
        do {
            try await service.addPhoto(samplePhoto, urlString: urlString)
        } catch {
            XCTFail("테스트에 사용될 사진 추가에 실패했습니다.")
            return
        }
        
        do {
            try await service.deletePhoto(of: samplePhoto.id)
        } catch {
            XCTFail("사진 삭제에 실패했습니다.")
        }
        
        let storedPhotos = try await service.fetchPhotos(myUser.name)
        XCTAssertFalse(storedPhotos.contains { $0.id == samplePhoto.id })
    }
}
