//
//  ProfileView.swift
//  FirebaseBootcamp
//
//  Created by Yasin Erdemli on 18.05.2023.
//

import SwiftUI

@MainActor final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    
    
    func loadCurrentUser() async throws {
        let userId = try AuthenticationManager.shared.getAuthenticatedUser().uid
        self.user = try await UserManager.shared.getUser(userId: userId)
    }
    
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    var body: some View {
        List {
            if let user = viewModel.user {
                Text("UserID: \(user.userID) ")
            }
            if let isAnonymous = viewModel.user?.isAnonymous {
                Text("Is Anonymous: \(isAnonymous.description.capitalized)")
            }
        }
        .onAppear {
            Task {
                try? await viewModel.loadCurrentUser()
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView(showSignInView: $showSignInView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }

            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView(showSignInView: .constant(false))
        }
    }
}
