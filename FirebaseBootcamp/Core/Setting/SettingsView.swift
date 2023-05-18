//
//  SettingsView.swift
//  FirebaseBootcamp
//
//  Created by Yasin Erdemli on 13.05.2023.
//

import SwiftUI



struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    var body: some View {
        List {
            Button("Sign Out") {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                    } catch {
                        print("Error \(error.localizedDescription)")
                    }
                }
            }
            
            Button(role: .destructive) {
                Task {
                    do {
                        try await viewModel.deleteAccount()
                        showSignInView = true
                    } catch {
                        print("Error \(error.localizedDescription)")
                    }
                }
            } label: {
                Text("Delete Account")
            }

            
            if viewModel.authProviders.contains(.email) {
                emailSection
            }
            
            if viewModel.authUser?.isAnoymous == true {
                anonymousSection
            }
        }
        .onAppear {
            try? viewModel.loadAuthProviders()
            viewModel.loadUser()
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView(showSignInView: .constant(false))
        }
    }
}

extension SettingsView {
    private var emailSection: some View {
        Section {
            Button("Reset Password") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("Password Reset!")
                    } catch {
                        print("Error \(error.localizedDescription)")
                    }
                }
            }
            
            Button("Update Password") {
                Task {
                    do {
                        try await viewModel.updatePassword(to: "1234567")
                        print("Password Update")
                    } catch {
                        print("Error \(error.localizedDescription)")
                    }
                }
            }
            
            Button("Update Email") {
                Task {
                    do {
                        try await viewModel.updateEmail(to: "yasinerdemli35@icloud.com")
                        print("Email Update")
                    } catch {
                        print("Error \(error.localizedDescription)")
                    }
                }
            }
        } header: {
            Text("Email Functions")
        }
    }
    
    private var anonymousSection: some View {
        Section {
            Button("Link Google Account") {
                Task {
                    do {
                        try await viewModel.linkGoogleAccount()
                    } catch {
                        print("Error \(error.localizedDescription)")
                    }
                }
            }
            
            Button("Link Apple Account") {
                Task {
                    do {
                        try await viewModel.linkAppleAccount()
                    } catch {
                        print("Error \(error.localizedDescription)")
                    }
                }
            }
            
            Button("Link Email Account") {
                Task {
                    do {
                        try await viewModel.linkEmailAccount(email: "test31@otuzbir.com", password: "123456")
                    } catch {
                        print("Error \(error.localizedDescription)")
                    }
                }
            }
        } header: {
            Text("Create Account")
        }
    }
}
