//
//  UserManager.swift
//  FirebaseBootcamp
//
//  Created by Yasin Erdemli on 18.05.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBUser: Codable {
    let userID: String
    let isAnonymous:  Bool?
    let email:  String?
    let photoURL:  String?
    let dateCreated:  Date?
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case isAnonymous = "is_anonymous"
        case email = "email"
        case photoURL = "photo_url"
        case dateCreated = "date_created"
    }
}

final class UserManager {
    
    static let shared = UserManager()
    
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("user")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    func createNewUser(auth: AuthDataResultModel) async throws {
        var userData: [String:Any] = [
            "user_id" : auth.uid,
            "is_anonymous" : auth.isAnoymous,
            "date_created" : Timestamp()
            
        ]
        if let email = auth.email {
            userData["email"] = email
        }
        if let photoUrl = auth.photoUrl {
            userData["photo_url"] = photoUrl
        }
        
        try await userDocument(userId: auth.uid).setData(userData, merge: false)
    }
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userID).setData(from: user, merge:  false)
        
    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
//    func getUser(userId: String) async throws -> DBUser {
//        let snapshot = try await userDocument(userId: userId).getDocument()
//        guard let data = snapshot.data(), let userID = data["user_id"] as? String else { throw URLError(.badServerResponse)}
//        let isAnonymous = data["is_anonymous"] as? Bool
//        let email = data["email"] as? String
//        let photoURL = data["photo_url"] as? String
//        let dateCreated = data["date_created"] as? Date
//
//        return .init(userID: userID, isAnonymous: isAnonymous, email: email, photoURL: photoURL, dateCreated: dateCreated)
//    }
//
}
