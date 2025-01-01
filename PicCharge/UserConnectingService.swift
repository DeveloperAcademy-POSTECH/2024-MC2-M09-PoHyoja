//
//  UserConnectingService.swift
//  PicCharge
//
//  Created by 남유성 on 12/28/24.
//

import Foundation

/// 연결 요청을 관리하는 Firestore 서비스 프로토콜
protocol ConnectionRequestService {
    
    /// 연결 요청을 추가합니다.
    /// - Parameters:
    ///   - currentUserName: 현재 사용자 이름
    ///   - otherUserName: 요청을 보낼 대상 사용자 이름
    /// - Throws: Firestore 작업 중 오류가 발생할 경우 예외를 던집니다.
    func addConnectRequests(currentUserName: String, otherUserName: String) async throws
    
    /// 사용자가 받은 연결 요청을 가져옵니다.
    /// - Parameter userName: 연결 요청을 받은 사용자 이름
    /// - Returns: 해당 사용자가 받은 연결 요청 목록
    /// - Throws: Firestore 작업 중 오류가 발생할 경우 예외를 던집니다.
    func fetchConnectionRequests(userName: String) async throws -> [ConnectionRequestsDTO]
    
    /// 사용자가 보낸 연결 요청 목록을 가져옵니다.
    /// - Parameter userName: 요청을 보낸 사용자 이름
    /// - Returns: 사용자가 보낸 연결 요청 목록
    /// - Throws: Firestore 작업 중 오류가 발생할 경우 예외를 던집니다.
    func listenRequest(from userName: String) async throws -> [ConnectionRequestsDTO]
    
    /// 사용자가 받은 연결 요청 목록을 가져옵니다.
    /// - Parameter userName: 요청을 받은 사용자 이름
    /// - Returns: 사용자가 받은 연결 요청 목록
    /// - Throws: Firestore 작업 중 오류가 발생할 경우 예외를 던집니다.
    func listenRequest(to userName: String) async throws -> [ConnectionRequestsDTO]
}
