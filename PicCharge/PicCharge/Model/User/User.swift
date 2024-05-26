//
//  User.swift
//  PicCharge
//
//  Created by 남유성 on 5/27/24.
//

import Foundation
import FirebaseFirestoreSwift

/**
 users
     `userID`: 아이디 (자동생성)
     
     - name (string): 이름 (고유해야 한다.)
     - role (string): 역할 (parent, child)
     - email(string): 이메일
     - connectedTo: ([String]): 연결된 유저의 이름
     - uploadCycle(null/number): 자식 역할일 경우 며칠에 한번 사진 올릴지 목표치
 
 예시
 ```json
 {
   "users": {
     "KDLOoKT7ishJQyofa3pITE8qh9f1": {
         "name": "조페더",
       "role": "parent",
       "email": "parent@google.com"
       "connectedTo": ["에이스"]
       "uploadCycle": null
     },
     "goNulJ3kBFOAHwDSGt0sRuT1JbD3": {
         "name": "에이스"
       "role": "child",
       "email": "child@naver.com"
       "connectedTo": ["조페더"]
       "uploadCycle": 3
     },
     ...
   }
 }
 ```
 */
struct User: Identifiable, Codable {
    @DocumentID var id: String? // Firestore의 문서 ID와 매핑
    var name: String
    var role: Role
    var email: String
    var connectedTo: [String] = []
    var uploadCycle: Int? = nil
}
