//
//  SignInAppleHelper.swift
//  FirebaseBootcamp
//
//  Created by Yasin Erdemli on 17.05.2023.
//

import Foundation
import AuthenticationServices
import SwiftUI
import CryptoKit

struct signInWithAppleResult {
    let nonce: String
    let token: String
    let credential: ASAuthorizationAppleIDCredential
    let email: String?
}

struct SignInWithAppleViewRepresentable: UIViewRepresentable {
    
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(authorizationButtonType: type, authorizationButtonStyle: style)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
@MainActor
final class SignInAppleHelper: NSObject {
    fileprivate var currentNonce: String?
    private var completionHandler: ((Result<signInWithAppleResult,Error>) -> Void)? = nil
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func startSignInWithAppleFlowAsync() async throws -> signInWithAppleResult {
        return try await withCheckedThrowingContinuation { continuation in
            startSignInWithAppleFlow { response in
                continuation.resume(with: response)
            }
        }
    }
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow(completion: @escaping(Result<signInWithAppleResult,Error>) -> Void) {
        guard let topVC = try? Utilities.shared.getTopViewController() else {
            completion(.failure(URLError(.badURL)))
            return
        }
        let nonce = randomNonceString()
        currentNonce = nonce
        completionHandler = completion
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = topVC
        authorizationController.performRequests()
    }
}

@available(iOS 13.0, *)
extension SignInAppleHelper: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8),
              let nonce = currentNonce else {
            completionHandler?(.failure(URLError(.cannotFindHost)))
            return
        }
        
        let email = appleIDCredential.email
        
        let tokens = signInWithAppleResult(nonce: nonce, token: idTokenString, credential: appleIDCredential, email: email)
        completionHandler?(.success(tokens))
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        completionHandler?(.failure(URLError(.cannotConnectToHost)))
        print("Sign in with Apple errored: \(error)")
    }
}


extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}


