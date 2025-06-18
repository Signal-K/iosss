//
//  Star_SailorsApp.swift
//  Star Sailors
//
//  Created by Liam Arbuckle on 18/6/2025.
//

import SwiftUI
import Supabase

@main
struct Star_SailorsApp: App {
    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    SuccessView()
                } else {
                    AuthView()
                }
            }
            .task {
                for await state in supabase.auth.authStateChanges {
                    if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                        authManager.isAuthenticated = state.session != nil
                    }
                }
            }
        }
    }
}

final class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
}

struct SuccessView: View {
    var body: some View {
        VStack {
            Text("🌟 Welcome aboard, Star Sailor!")
                .font(.title)
                .foregroundColor(.green)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundWhite)
        .ignoresSafeArea()
    }
}

#Preview {
    SuccessView()
}
