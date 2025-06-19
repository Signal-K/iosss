//
//  ProfileView.swift
//  Star Sailors
//
//  Created by Liam Arbuckle on 19/6/2025.
//

import SwiftUI
import Supabase

struct ProfileView: View {
    @State var username = ""
    
    @State var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Profile")
                            .font(.largeTitle.bold())
                            .foregroundColor(.textPrimary)
                        
                        Group {
                            InputField(title: "Username", text: $username)
                        }
                        
                        if isLoading {
                            ProgressView()
                                .tint(.gardenGreen)
                        }
                        
                        Button(action:
                                updateProfileButtonTapped) {
                            Text("Update Profile")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gardenGreen)
                                .foregroundColor(.white)
                                .cornerRadius(0)
                                .overlay(
                                    RoundedRectangle (cornerRadius: 0)
                                        .stroke(Color .black, lineWidth: 1.5)
                                )
                        }
                    }
                    
                    .padding()
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        try? await
                            supabase.auth.signOut()
                    }
                }) {
                    Text("Sign Out")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color.black, lineWidth: 1.5)
                        )
                }
                
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            
            .background(Color.surfaceGray)
                .ignoresSafeArea()
        }
        
        .task {
            await getInitialProfile()
        }
    }
    
    func getInitialProfile() async {
        do {
            let currentUser = try await supabase.auth.session.user
            let profile: Profile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: currentUser.id)
                .single()
                .execute()
                .value
            
            self.username = profile.username ?? ""
        } catch {
            debugPrint(error)
        }
    }
    
    func updateProfileButtonTapped() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                let currentUser = try await supabase.auth.session.user
                
                try await supabase
                    .from("profiles")
                    .update(
                        UpdateProfileParams(
                            username: username
                        )
                    )
                    .eq("id", value: currentUser.id)
                    .execute()
            } catch {
                debugPrint(error)
            }
        }
    }
}

#Preview {
 ProfileView()
}

#Preview {
    ProfileView()
}

struct InputField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(.textPrimary)
            
            TextField("", text: $text)
                .padding(10)
                .background(Color.backgroundWhite)
                .overlay(
                    Rectangle()
                        .stroke(Color.black, lineWidth: 1.5)
                )
                .font(.body)
                .autocorrectionDisabled()
        }
    }
}
