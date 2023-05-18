//
//  AuthenticationView.swift
//  FirebaseBootcamp
//
//  Created by Yasin Erdemli on 13.05.2023.
//

import SwiftUI
import GoogleSignInSwift


struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    var body: some View {
        VStack {
            
            Button {
                Task {
                    do {
                        try await viewModel.signInAnoymous()
                        showSignInView = false
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } label: {
                Text("Sign In Anonymously")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background {
                        Color.orange
                    }
                    .cornerRadius(10)
            }

            
            NavigationLink {
                SignInEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Sign In With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background {
                        Color.blue
                    }
                    .cornerRadius(10)
            }
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        self.showSignInView = false
                    } catch {
                        print("Error Sign In With Google")
                    }
                }
            }
            Button(action: {
                Task {
                    do {
                        try await viewModel.signInApple()
                        showSignInView.toggle()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }, label: {
                SignInWithAppleViewRepresentable(type: .default, style: .black)
                    .allowsHitTesting(false)
            })
                .frame(height: 55)
            
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In")
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(showSignInView: .constant(true))
        }
    }
}
