//
//  TabMenu.swift
//  Star Sailors
//
//  Created by Liam Arbuckle on 19/6/2025.
//

import SwiftUI

struct TabMenu: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        
        .accentColor(.gardenGreen)
    }
}

#Preview {
    TabMenu()
}
