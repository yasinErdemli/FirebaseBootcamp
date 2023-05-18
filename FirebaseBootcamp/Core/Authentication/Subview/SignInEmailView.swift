//
//  SignInEmailView.swift
//  FirebaseBootcamp
//
//  Created by Yasin Erdemli on 13.05.2023.
//

import SwiftUI

@MainActor
final class SignInEmailViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No Email or Password Found")
            return
        }
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        try await UserManager.shared.createNewUser(auth: authDataResult)
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No Email or Password Found")
            return
        }
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
        
    }
    
}

struct SignInEmailView: View {
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    var body: some View {
        VStack {
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background {
                    Color.gray.opacity(0.4)
                }
                .cornerRadius(10)
            
            SecureField("Password...", text: $viewModel.password)
                .padding()
                .background {
                    Color.gray.opacity(0.4)
                }
                .cornerRadius(10)
            
            Button {
                Task {
                    do {
                        try await viewModel.signUp()
                        showSignInView = false
                        return
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    do {
                        try await viewModel.signIn()
                        showSignInView = false
                        return
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } label: {
                Text("Sign In")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background {
                    Color.blue
                }
                .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In with E-Mail")
    }
}

struct SignInEmailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignInEmailView(showSignInView: .constant(false))
        }
    }
}
