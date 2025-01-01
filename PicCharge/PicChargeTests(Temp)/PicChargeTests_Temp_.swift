//
//  PicChargeTests_Temp_.swift
//  PicChargeTests(Temp)
//
//  Created by 남유성 on 1/1/25.
//

import XCTest
@testable import PicCharge_Dev

final class PicChargeTests_Temp_: XCTestCase {
    
    private var service: FirebaseService!
    
    private let unknownUser = User(name: "unknown", role: .child, email: "user@unknown.com", connectedTo: [])
    private let myUser = User(name: "myUser", role: .child, email: "user@my.com", connectedTo: [])
    private let userForDelete = User(name: "userForDelete", role: .child, email: "user@delete.com", connectedTo: [])
    
    override func setUpWithError() throws {
        let isTest = true
        
        if isTest {
            service = FirebaseService(isTest: isTest)
        } else {
            fatalError("테스트 여부 확인!!!!!!!!!!")
        }
        
        
        // 데이터를 비동기적으로 생성하고 기다림
        let expectation = self.expectation(description: "Setup Test Data")
        
        Task {
            do {
                // 테스트 데이터를 생성
                try await service.addUser(myUser)
                expectation.fulfill() // 데이터 생성이 완료되면 기대치를 충족
            } catch {
                XCTFail("Failed to create test data: \(error)")
            }
        }
        
        // 비동기 작업이 완료될 때까지 기다림 (최대 5초)
        wait(for: [expectation], timeout: 5.0)
    }
    
    override func tearDownWithError() throws {
        // 데이터를 비동기적으로 생성하고 기다림
        let expectation = self.expectation(description: "Delete Test Data")
        
        Task {
            do {
                // 테스트 데이터를 생성
                try await service.clearTests()
                service = nil
                expectation.fulfill() // 데이터 생성이 완료되면 기대치를 충족
            } catch {
                XCTFail("Failed to create test data: \(error)")
                service = nil
            }
        }
        
        // 비동기 작업이 완료될 때까지 기다림 (최대 5초)
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_없는유저_이메일로_조회() async throws {
        let fetchUser = await service.fetchUserByEmail(unknownUser.email)
        
        XCTAssertNil(fetchUser) // nil
    }
    
    func test_기존유저_이메일로_조회() async throws {
        let fetchUser = await service.fetchUserByEmail(myUser.email)
        
        XCTAssertNotNil(fetchUser)
        XCTAssertEqual(fetchUser?.name, myUser.name)
        XCTAssertEqual(fetchUser?.email, myUser.email)
    }
    
    func test_없는유저_이름으로_조회() async throws {
        let fetchUser = await service.fetchUserByName(unknownUser.name)
        
        XCTAssertNil(fetchUser) // nil
    }
    
    func test_기존유저_이름으로_조회() async throws {
        let fetchUser = await service.fetchUserByName(myUser.name)
        
        XCTAssertNotNil(fetchUser)
        XCTAssertEqual(fetchUser?.name, myUser.name)
        XCTAssertEqual(fetchUser?.email, myUser.email)
    }
    
    func test_유저존재여부_확인() async throws {
        let isUnknownExist = try await service.checkUserExists(by: unknownUser.name)
        let isMyUserExist = try await service.checkUserExists(by: myUser.name)
        
        XCTAssertFalse(isUnknownExist)
        XCTAssertTrue(isMyUserExist)
    }
    
    func test_신규유저_추가() async throws {
        let newUser = User(name: "newUser", role: .child, email: "newUser@newUser.com", connectedTo: [])
        try await service.addUser(newUser)
        
        let fetchUser = await service.fetchUserByName(newUser.name)
        XCTAssertNotNil(fetchUser)
        XCTAssertEqual(fetchUser?.name, newUser.name)
        
        do {
            try await service.addUser(newUser)
            XCTFail("유저 중복 생성 불가")
        } catch {
            
        }
    }
    
    func test_기존유저_삭제() async throws {
        try await service.deleteUser(userForDelete)
        
        let fetchUser = await service.fetchUserByName(userForDelete.name)
        XCTAssertNil(fetchUser)
    }
}
