//
//  AuthenticationManager.swift
//  FirebaseBootcamp
//
//  Created by Yasin Erdemli on 13.05.2023.
//

import Foundation
import FirebaseAuth
import AuthenticationServices

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    let isAnoymous: Bool
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isAnoymous = user.isAnonymous
    }
    
}

enum AuthProviderOption: String {
    case google = "google.com"
    case email = "password"
    case apple = "apple.com"
}

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    
    private init() {
    }
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        return AuthDataResultModel(user: user)
    }
    
    func getProvider() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else { throw URLError(.badServerResponse) }
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID)  {
                providers.append(option)
            } else {
                assertionFailure()
            }
        }
        return providers
    }
   
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    
    func delete() async throws {
        guard let user = Auth.auth().currentUser else { throw URLError(.cannotFindHost) }
        try await user.delete()
    }
    
}

// MARK: Sign In Email
extension AuthenticationManager {
    
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let user = authDataResult.user
        return AuthDataResultModel(user: user)
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResults = try await Auth.auth().signIn(withEmail: email, password: password)
        let user = authDataResults.user
        return AuthDataResultModel(user: user)
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(to password: String) async throws {
        guard let user = Auth.auth().currentUser else { throw URLError(.cannotOpenFile) }
        try await user.updatePassword(to: password)
    }
    
    func updateEmail(to email: String) async throws {
        guard let user = Auth.auth().currentUser else { throw URLError(.cannotOpenFile)}
        try await user.updateEmail(to: email)
    }
}

// MARK: Sign In SSO
extension AuthenticationManager {
    @discardableResult func SignInWithGoogle(tokens: GoogleSignInResultModel ) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await SignIn(credential: credential)
    }
    
    @discardableResult func SignInWithApple(tokens: signInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.appleCredential(withIDToken: tokens.token, rawNonce: tokens.nonce, fullName: tokens.credential.fullName)
        
        return try await SignIn(credential: credential)
    }
    
    func SignIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
// MARK: Sign In Anonymously
extension AuthenticationManager {
    @discardableResult
    func signInAnonymously() async throws -> AuthDataResultModel{
        let user = try await Auth.auth().signInAnonymously()
        return AuthDataResultModel(user: user.user)
    }
    
    func linkEmail(email: String, password: String) async throws -> AuthDataResultModel {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        return try await linkCredential(credential: credential)
    }
    
    func linkGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        
        return try await linkCredential(credential: credential)
    }
    
    func linkApple(tokens: signInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.appleCredential(withIDToken: tokens.token, rawNonce: tokens.nonce, fullName: tokens.credential.fullName)
        
        return try await linkCredential(credential: credential)
    }
    
    private func linkCredential(credential: AuthCredential) async throws ->  AuthDataResultModel {
        guard let user = Auth.auth().currentUser else { throw URLError(.badURL)}
        
        let authDataResult = try await user.link(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
