//
//  AuthenticationViewModel.swift
//  FirebaseBootcamp
//
//  Created by Yasin Erdemli on 18.05.2023.
//

import Foundation


@MainActor final class AuthenticationViewModel: ObservableObject {
    
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.SignInWithGoogle(tokens: tokens)
        let user = DBUser(userID: authDataResult.uid, isAnonymous: authDataResult.isAnoymous, email: authDataResult.email, photoURL: authDataResult.photoUrl, dateCreated: Date())
        try await UserManager.shared.createNewUser(user: user )
    }
    
    func signInApple() async throws  {
        let appleHelper = SignInAppleHelper()
        let tokens = try await appleHelper.startSignInWithAppleFlowAsync()
        let authDataResult = try await AuthenticationManager.shared.SignInWithApple(tokens: tokens)
        let user = DBUser(userID: authDataResult.uid, isAnonymous: authDataResult.isAnoymous, email: authDataResult.email, photoURL: authDataResult.photoUrl, dateCreated: Date())
        try await UserManager.shared.createNewUser(user: user )
    }
    
    func signInAnoymous() async throws {
        let authDataResult = try await AuthenticationManager.shared.signInAnonymously()
        let user = DBUser(userID: authDataResult.uid, isAnonymous: authDataResult.isAnoymous, email: authDataResult.email, photoURL: authDataResult.photoUrl, dateCreated: Date())
        try await UserManager.shared.createNewUser(user: user )
    }
}
