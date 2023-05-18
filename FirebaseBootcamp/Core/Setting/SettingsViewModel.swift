//
//  SettingsViewModel.swift
//  FirebaseBootcamp
//
//  Created by Yasin Erdemli on 18.05.2023.
//

import Foundation


@MainActor final class SettingsViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    @Published var authUser: AuthDataResultModel? = nil
    
    func loadAuthProviders() throws {
        authProviders = try AuthenticationManager.shared.getProvider()
    }
    
    func loadUser() {
        authUser = try?  AuthenticationManager.shared.getAuthenticatedUser()
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func deleteAccount() async throws {
        try await AuthenticationManager.shared.delete()
    }
    
    func resetPassword() async throws {
        let auth = try AuthenticationManager.shared.getAuthenticatedUser()
        guard let userEmail = auth.email else { throw URLError(.badServerResponse) }
        try await AuthenticationManager.shared.resetPassword(email: userEmail)
    }
    
    func updatePassword(to password: String) async throws {
        try await AuthenticationManager.shared.updatePassword(to: password)
    }
    
    func updateEmail(to email: String) async throws {
        try await AuthenticationManager.shared.updateEmail(to: email)
    }
    
    func linkGoogleAccount() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        self.authUser = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
    }
    
    func linkAppleAccount() async throws {
        let appleHelper = SignInAppleHelper()
        let tokens = try await appleHelper.startSignInWithAppleFlowAsync()
        self.authUser = try await AuthenticationManager.shared.linkApple(tokens: tokens)
    }
    
    func linkEmailAccount(email: String, password: String) async throws {
        self.authUser = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
    }
}
