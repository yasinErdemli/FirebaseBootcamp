//
//  SignInGoogleHelper.swift
//  FirebaseBootcamp
//
//  Created by Yasin Erdemli on 15.05.2023.
//

import Foundation
import GoogleSignIn


struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
    let name: String?
    let email: String?
}


actor SignInGoogleHelper {
    
    @MainActor func signIn() async throws -> GoogleSignInResultModel {
        let viewController = try Utilities.shared.getTopViewController()
        
        let SignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
        guard let IdToken = SignInResult.user.idToken?.tokenString else { throw URLError(.cannotFindHost) }
        let accesToken = SignInResult.user.accessToken.tokenString
        let name = SignInResult.user.profile?.name
        let email = SignInResult.user.profile?.email
        return GoogleSignInResultModel(idToken: IdToken, accessToken: accesToken, name: name, email: email)
    }
}
