//
//  RootView.swift
//  FirebaseBootcamp
//
//  Created by Yasin Erdemli on 13.05.2023.
//

import SwiftUI

struct RootView: View {
    @State private var showSignInView: Bool = false
    var body: some View {
        ZStack {
            if showSignInView == false {
                NavigationStack {
                    ProfileView(showSignInView: $showSignInView)
                }
            }
        }
        .onAppear {
            let authenticatedUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authenticatedUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
